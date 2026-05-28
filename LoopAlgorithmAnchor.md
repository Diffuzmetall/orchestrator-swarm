# Loop Algorithm Anchor

**Слаб-напоминалка для каждого тика `/loop`.** Читай **в начале каждого Cycle** (до шагов 1–20 в `LoopPrompt.md`). Полная процедура — `AlgorithmIntegration.md`.

---

## Одна строка (держи в голове)

> Swarm — это **EXECUTE-фаза одного PRD**, не «просто крутить beads». Beads — тактика; **ISC + `progress: M/N`** — источник истины для «куда мы идём».

---

## Активный PRD (проверь каждый тик)

```bash
# если путь забыт — последний PRD по mtime в репо
ls -t MEMORY/WORK/*/PRD.md 2>/dev/null | head -1
```
| Проверка | Ожидание на looper-тиках |
| --- | --- |
| `phase` в frontmatter | **`execute`** (не `verify` / `learn` / `complete` до saturation) |
| `## Criteria` | ISC-чекбоксы `- [ ]` / `- [x]` |
| `progress: M/N` | Совпадает с числом `[x]` в Criteria |
| `updated` | Обновлялся при последнем ISC/bead sync |

**Если PRD не найден** — стоп координации «вслепую»: fallback по `AlgorithmIntegration.md` → **Fallback: PRD не найден** (спроси пользователя; не делай stub без «да»).

---

## Чеклист: этот тик (~3 min, каждый Cycle)

Выполни **до** операционных шагов looper (panes, Mail, beads):

0. **Rules refresh:** **`RulesRefresh.md`** — **проект** `<repo>/AGENTS.md` + `<repo>/CLAUDE.md` **каждый тик**; **глобальные** `$GLOBAL_AGENTS.md` (see `docs/ECOSYSTEM.md`) + `~/.claude/CLAUDE.md` — **каждый ~3-й тик** (и всегда на digest-тике).
1. **Прочитай** frontmatter активного PRD (`task`, `phase`, `progress: M/N`).
2. **Сверь** `br list --status closed` (или Mail/reviewer) с beads, закрытыми **с прошлого тика** — для каждого: mapping → ISC? (`AlgorithmIntegration.md` → **Mapping: bead close → ISC update**).
3. **Edit PRD** при прямом покрытии ISC: `- [ ]` → `- [x]`, `progress: M+1/N`, `updated: <ISO>`.
4. **Не помечай ISC `[x]` авансом**, если reviewer/QA ещё не подтвердили или bead лишь часть составного ISC.
5. **Не создавай второй PRD** и не уходи в «чисто операционный» режим без PRD.

---

## Чеклист: digest-тик (~16 min wall-clock, sub-VERIFY)

Дополнительно к чеклисту выше + `RealityCheckDigest.md`:

1. Прочитать PRD целиком (`## Criteria`, `## Verification`).
2. Сверить **каждый** ISC с `main` (коммиты, тесты, capture panes).
3. **Edit PRD `## Verification`** — evidence по новым ISC (BD-ID, commit, test, capture).
4. **`phase` остаётся `execute`** — не ставь `verify` на digest-тике.
5. В человеко-сводке: строка `PRD <slug>: progress M/N; evidence для ISC-…`.
6. Edit PRD `## Verification` — evidence; Q1–Q3 в digest (формальный JSONL — в LEARN).

Подробности: `AlgorithmIntegration.md` → **Reality-check digest = sub-VERIFY pass**.

---

## Чеклист: AFK exit (пауза без человека, не LEARN)

**Когда:** AFK-режим (LaunchAFK / «ухожу спать» / оператор не отвечает). См. **`AFKExitHandoff.md`**.

**Каждый looper-тик (~3 min):**

1. Обнови `afk_stall_loops` (+1 если нет прогресса: bead close, ISC `M/N`, видимая работа в pane).
2. Если `afk_stall_loops >= 6` **или** немедленный триггер (невосстановимый блокер после 1 recovery, пустой граф ready+in_progress, флот мёртв) → **стоп**:
   - `/loop stop`
   - Mail «AFK PAUSE» на panes
   - Запиши **`docs/swarm-afk-exit-handoff.md`** по шаблону
   - PRD `phase` остаётся `execute` (если не saturation)
3. **Не** спрашивай пользователя; **не** начинай следующий тик после exit.

---

## Чеклист: saturation / stop (LEARN, один раз)

Триггеры: все ISC `[x]` + нет open/stalled; пользователь «стоп»; нельзя двигать остаток без вне swarm.

1. `phase: verify` → финальный VERIFY по всем ISC.
2. `phase: learn` → Algorithm Q1–Q3 + append `docs/swarm-learnings/reflections.jsonl`.
3. `phase: complete`.
4. Сообщить пользователю: что закрыто / не закрыто / главный вывод.

Подробности: `AlgorithmIntegration.md` → **LEARN: завершение swarm**. После этого **останови** `/loop`.

---

## Антипаттерны (ловушки looper)

| Антипаттерн | Почему плохо |
| --- | --- |
| Закрыли beads, PRD не трогали | Digest и `progress` врут; Algorithm сломан |
| Поставили `phase: verify` на каждом digest | VERIFY — один раз в LEARN, digest = sub-VERIFY |
| Новый PRD «для swarm» | Один PRD на работу; swarm = EXECUTE существующего |
| Только bead-count в reality-check | План = ISC + stage docs, не счётчик BD |
| AFK + бесконечный `/loop` без handoff | Человек возвращается к неизвестному состоянию; нужен `swarm-afk-exit-handoff.md` |

---

## Связанные файлы

| Файл | Роль |
| --- | --- |
| `LoopPrompt.md` | Операционные шаги 1–20 + `/loop 3m` bootstrap |
| `AlgorithmIntegration.md` | Полный lifecycle PRD ↔ swarm |
| `RealityCheckDigest.md` | Формат человеко-сводки + PRD Verification |
| `docs/PRD-FORMAT.md` | Формат PRD |
| `MemoryIntegration.md` | session memory (optional; see `MemoryIntegration.md`) по фазам Algorithm |
| `RulesRefresh.md` | AGENTS.md + CLAUDE.md (global + project) cadence |
| `AFKExitHandoff.md` | Стоп looper в AFK, stall counter, exit handoff |
| `docs/planning/algorithm.md` (optional) | Фазы Algorithm |
