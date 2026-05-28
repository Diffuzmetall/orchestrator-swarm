# AFK Exit — остановка looper без бесконечного круга

**Когда:** swarm запущен в **AFK** (пользователь «ухожу спать», «без вопросов», LaunchAFK, нет ответов в чате). Оператор **недоступен**.

**Цель:** looper **не** крутится бесконечно без прогресса. После **5–7** тиков без движения или при **невосстановимом блокере** — **стоп** `/loop` + **детальный handoff** для человека.

---

## Правила AFK (NON-NEGOTIABLE)

| Делать | Не делать |
|--------|-----------|
| Вести счётчик `afk_stall_loops` каждый тик (~3 min) | Спрашивать пользователя между тиками |
| Писать `docs/swarm-afk-exit-handoff.md` при выходе | Ждать «да» на продолжение loop |
| Один recovery на блокер → exit handoff | Крутить 4+ часа один и тот же bead |
| Mail broadcast «AFK pause» на panes | Игнорировать 6+ тиков без bead close / ISC |

Счётчик храни в **PRD `## Decisions`** (одна строка на тик) или в начале каждого digest — чтобы пережить compact:

```markdown
- AFK stall loops: 3/6 (last progress: closed yandex-ads-mcp-hub-jrra @ commit abc123)
```
---

## Счётчик `afk_stall_loops`

**+1** в конце тика, если **ни одного** из событий прогресса:

- Закрыт bead с evidence (commit / тест / capture)
- `progress: M/N` в PRD вырос
- Новый `in_progress` с видимой работой в `tmux capture-pane`
- Снят блокер, который держал граф 2+ тика

**Сброс в 0**, если было **любое** событие прогресса выше.

**Порог выхода:** `afk_stall_loops >= 6` (диапазон 5–7; по умолчанию **6** ≈ ~18 min при 3 min тиках).

---

## Немедленный выход (без ожидания 6 тиков)

Останови loop и пиши handoff, если **любое**:

1. **Невосстановимый блокер** — одна попытка recovery по `docs/swarm-blockers.md` / AgentMailRunbook **не помогла** (Mail down, quota на всех cod, git broken, scope impossible).
2. **Agent Mail fail-closed** и repair не удался — не координируй вслепую.
3. **Нет ready/open beads** и **нет** `in_progress` с прогрессом **после** проверки Mail + `bv --robot-next` — swarm **ждёт человека** (scope, ключи, решение).
4. **Критическая деградация флота** — большинство panes dead/zsh/errors, failover исчерпан.
5. Пользователь явно написал «стоп» / «хватит» (если всё же ответил).

**Нормальный выход (saturation):** все ISC `[x]`, review чистый → `LoopAlgorithmAnchor.md` LEARN → handoff **не** AFK-exit, а completion summary (можно тот же файл с `exit_reason: saturation`).

---

## Процедура остановки (каждый AFK exit)

### 1. Зафиксировать причину

В PRD `## Decisions`:

```markdown
- AFK exit @ <ISO>: reason=stall|blocker|idle_graph|fleet_dead|user_stop; stall_loops=N
```
### 2. Остановить looper

На **orchestrator pane** (cc):

```text
/loop stop
```
Если встроенный `/loop stop` недоступен — отмени активный loop тем способом, который поддерживает среда; **не** запускай новый `/loop 3m …`.

### 3. Остановить роли (Mail)

Одно broadcast (Agent Mail или `ntm --robot-send="$PROJECT" --all --msg="..."` **коротко**):

```text
AFK PAUSE: orchestrator остановил looper. Не бери новые beads. Заверши текущий атомарный шаг, commit если готов, ответь в Mail статусом. Self-loop не запускай до resume от человека.
```
### 4. Записать handoff (обязательно)

**Путь в репо (всегда):**

```text
docs/swarm-afk-exit-handoff.md
```
**Дополнительно**, если есть slug:

```text
repo `MEMORY/WORK/` or `docs/work/`<slug>/SWARM-AFK-EXIT.md
```
Используй шаблон ниже. `br sync --flush-only` если были изменения beads.

### 5. Не удалять сессию

`ntm` session оставь живой — человек подключится `ntm attach`. В handoff укажи `ntm_session` и pane map.

---

## Шаблон `docs/swarm-afk-exit-handoff.md`

```markdown
---
exit_at: <ISO-8601>
exit_reason: stall_loops | unrecoverable_blocker | idle_graph | fleet_dead | saturation | user_stop
afk_stall_loops: <N>
ntm_session: <basename>
repo: <absolute path>
prd: <path>
handoff_source: <SWARM-HANDOFF path if any>
operator_available: false
---

# AFK Exit Handoff

## Почему остановились

<2–4 предложения: счётчик stall, блокер, отсутствие ready beads, и т.д.>

## Сделано

| Bead | Статус | Evidence (commit / test / note) |
|------|--------|----------------------------------|
| … | closed / in_progress | … |

### PRD / ISC

- progress: **M/N**
- ISC отмечены: <список или «см. PRD»>
- Commits на main (если пушили): <hash messages>

## Не сделано

| Bead / ISC | Почему не закрыто |
|------------|-------------------|
| … | blocked by … / not started / in_progress stalled |

## Блокеры

1. <блокер> — попытка recovery: <что делали> — результат: fail
2. См. также: `docs/swarm-blockers.md`

## Состояние флота (на момент exit)

| Pane | Role | Agent | Состояние (1 строка) |
|------|------|-------|----------------------|
| 1 | orch | cc | … |
| 2 | QA | cc | … |
| 3–8 | worker/review | cod | … |
| 9 | review | gmi | … |

## Риски / долги

- <тесты не гонялись, секреты, незакоммиченное, конфликт резерваций>

## Как продолжить (для человека)

1. Прочитать этот файл + `docs/swarm-blockers.md` + `SWARM-HANDOFF.md`
2. `ntm attach <session>` — проверить panes
3. Разрулить блокеры из § Блокеры
4. Orchestrator pane: сбросить `afk_stall_loops` в PRD Decisions, снова `/loop 3m /OrchestratorSwarm continue swarm execution — read LoopAlgorithmAnchor.md first`
5. При необходимости re-dispatch только на idle panes (`RobotSendDispatch.md`)

## Resume checklist

- [ ] Блокеры сняты
- [ ] Mail / doctor OK
- [ ] `bv --robot-next` не пустой ИЛИ явное решение сузить scope
- [ ] Looper перезапущен осознанно
```
---

## Связь с Algorithm

- AFK exit **≠** LEARN: `phase` остаётся **`execute`**, если ISC не все `[x]`.
- В PRD `## Verification`** добавь строку:** «AFK pause @ ISO — см. docs/swarm-afk-exit-handoff.md».
- Полный LEARN (`verify` → `learn` → `complete`) — только при saturation или явном «стоп + закрываем проект».

---

## Orchestrator: каждый looper-тик в AFK

В **конце** Cycle body (`LoopPrompt.md`):

```text
AFK gate: обнови afk_stall_loops. Если >= 6 или немедленный триггер — выполни AFKExitHandoff.md (stop loop + write docs/swarm-afk-exit-handoff.md). Не начинай следующий тик.
```
---

## Связанные файлы

| Файл | Роль |
|------|------|
| `LoopPrompt.md` | AFK gate в конце цикла |
| `LoopAlgorithmAnchor.md` | Чеклист AFK exit vs LEARN |
| `LaunchAFK.md` | AFK launch + exit policy |
| `OperatingProcedure.md` | Completion vs AFK pause |
| `Gotchas.md` | Anti infinite loop |
