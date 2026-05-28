# PaneRecapReading — глубокое чтение panes

> Покрывает разрыв между «pane закрыл bead» и «orchestrator уверен в качестве». Полагаться только на `bv open/closed` или `is_working` — это shallow polling: ровно та же ошибка, из-за которой R1 reviewer'ы открыли follow-up defects «closed without evidence».

---

## Принцип

**Закрытый bead ≠ выполненная работа.** Прежде чем заявлять "victory", orchestrator обязан прочитать что pane реально сказал — не статус, а вывод. Для каждого закрытого/in-progress bead собирается evidence trail из трёх слоёв:

1. **Recap-блок pane** — пишется в момент завершения шага (PAI NATIVE/MINIMAL mode header: `🗒️ TASK / 🔧 CHANGE / ✅ VERIFY / 🗣️ agent recap`)
2. **Bead close reason** — что pane записал в `br update ... --reason`
3. **Артефакты на диске** — файлы, патчи, NDJSON логи, коммиты которые pane обещал создать

Поверхностная проверка одного слоя пропускает FAIL'ы. Триангуляция трёх слоёв ловит их.

---

## Когда применять

| Триггер | Глубина |
|---|---|
| Looper тик (~3 мин) | Shallow: count open/closed + last 8 строк per pane |
| Перед reality-check digest (~16 мин) | **Medium** — этот файл, шаги 1–3 |
| Перед "victory" заявлением user'у | **Deep** — этот файл, все шаги 1–4 |
| Bead закрылся за <2 мин (подозрительно быстро) | **Deep** немедленно |
| Pane показал FAIL signals в буфере (errors, "absent", "skip", "fallback") | **Deep** немедленно |

---

## Протокол (medium → deep)

### Шаг 1 — Captures (~30 lines per pane)

Никогда не полагайся на `ntm --robot-is-working` или `bv` triage в одиночку. Для каждой целевой pane:

```bash
/usr/bin/tmux capture-pane -p -t <session>:<window>.<pane> -S -30 2>&1 | tail -30
```
`-S -30` забирает ~30 строк scrollback, что обычно содержит весь recap-блок NATIVE/MINIMAL mode + начало следующего turn.

### Шаг 2 — Извлечение Recap-блока

NATIVE и MINIMAL mode pane всегда пишет блок такого вида:

```
════ PAI | NATIVE MODE ═══════════════════════
🗒️ TASK: [8 слов]
📃 CONTENT: [то что реально сделал]
🔧 CHANGE: [bullets что изменилось]
✅ VERIFY: [bullets как проверил]
🗣️ agent recap: [8-16 слов резюме]
```
**🗣️ agent recap** — это **самый плотный** одностраничный summary. Прочитай его обязательно. Если pane не использовал NATIVE mode (например, codex/gemini не пишут header'ы) — ищи аналог: финальный summary параграф, последний tool-output, `br update --reason ...`, или explicit "Done." statement.

Записывай для каждой pane в свою заметку:

```
pane 1.5 (cod_2 → pai-x8a):
  🗣️ agent recap: "sha256 sidecar pushed, verified, bead closed with evidence"
  ✅ VERIFY claims: SHA256SUMS.txt committed to off-host repo, sha256sum -c PASS
  суспициозно?: нет
```
### Шаг 3 — Cross-check с bead close reason

```bash
br show <bead-id> --json | jq -r '.[0] | "STATUS: \(.status)\nUPDATED: \(.updated_at)\nREASON: \(.close_reason // .notes // "n/a")"'
```
Сверь:
- Hermes-summary говорит то же что close reason?
- Close reason ссылается на конкретные артефакты (paths, SHA, commit IDs)?
- Или close reason — generic ("done", "fixed", "implemented")? Generic = red flag.

### Шаг 4 — Verify артефакты на диске (DEEP)

Если Hermes-summary упоминает конкретный артефакт — **проверь его существование и содержимое**:

```bash
# Файл создан?
test -f <path> && echo "✓ exists" || echo "✗ MISSING"

# Executable если script?
test -x <path> && echo "✓ exec"

# Содержит что обещано?
head -20 <path>

# Если NDJSON — валидный?
jq -e . <path> >/dev/null 2>&1 && echo "✓ valid jsonl" || echo "✗ malformed"

# Если git push — реально в remote?
git -C <repo> log --oneline origin/main..HEAD  # ahead = не запушено
git -C <repo> ls-remote origin                 # remote доступен
```
Для off-host pushes — clone в `/tmp/verify-<bead>` и проверь что claim соответствует remote, а не локальной копии.

---

## Red flags при чтении recap-блоков

Если видишь в pane буфере любой из этих сигналов — **углубляйся, не закрывай глаза**:

- `absent`, `missing`, `MISSING`, `not found`, `n/a`
- `SKIP`, `skipped`, `skip because`
- `fallback`, `FALLBACK`, `cannot reach`
- `ECONNREFUSED`, `timed out`, `connection refused`
- `FAIL`, `failed`, `failure`
- `mock`, `stub`, `placeholder`, `TODO`, `XXX`
- `as if`, `simulated`, `dry-run` (если не было явного dry-run)
- Hermes-summary с hedging: «hopefully», «should», «assumed», «approximated»
- Close reason содержит "n/a", "best effort", "partial"

Эти токены означают что pane либо нашёл реальную проблему (но всё равно закрыл bead), либо deferred часть работы. R1 review такие закрытия отлавливает — ты должен отловить раньше.

---

## Что делать если recap unclear или suspect

1. **Прочти ширший контекст** — `tmux capture-pane -S -200` (последние 200 строк). Это покажет полную цепочку tool calls + outputs, не только финальный summary.
2. **Прочти close reason полностью** — не только первая строка, весь `--json` payload.
3. **Прочти артефакты целиком** — не `head`, а `cat` или `wc -l` + spot-check середины.
4. **Сравни с ISC** — открой исходный dispatch-prompt (`/tmp/swarm-r1cleanup/w-*.txt`), сверь каждый `[ ]` ISC item с реальностью.
5. **Если всё равно неясно — Agent Mail** работнику: `send_message` с конкретным вопросом ("ISC-3 говорит NDJSON в OBSERVABILITY/, где файл?"). Не угадывай.
6. **Эскалируй user'у** короткой honest заметкой: «pane X закрыл bead Y, но ISC-N не верифицируется потому что Z — продолжать или открыть follow-up defect?»

---

## Anti-patterns (что я (orchestrator) уже делал и не должен повторять)

- **Полагаться на `bv open=0`** как доказательство victory — это только count
- **`is_working: false`** — может значить «работа сделана» или «pane подвис» или «momentary idle между cycles»
- **Tail -8 строк** — недостаточно для recap-блока (он часто 12-20 строк)
- **Игнорировать FAIL-signals** в scrollback потому что bead уже closed
- **Verbal "victory" report пользователю** без шага 4 — это ровно то воспроизведение паттерна R1-defects «closed without evidence»

---

## Связанные файлы

- `OperatingProcedure.md` — общий SOP + где это вписывается в loop
- `LoopPrompt.md` — looper steps; medium-depth read обязателен на каждом ~16-мин тике
- `RealityCheckDigest.md` — формат отчёта; deep-read предшествует
- `Gotchas.md` — NTM Activity vs tmux capture-pane
- `AlgorithmIntegration.md` — sub-VERIFY pass на PRD ISC через эту процедуру
