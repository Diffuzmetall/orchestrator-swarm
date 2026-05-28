# Algorithm Integration (MANDATORY)

`/OrchestratorSwarm` — это **исполнитель EXECUTE-фазы существующего PRD**, а не отдельная Algorithm-арка.
Один PRD на работу. Swarm не создаёт второй, не делает свой «meta-PRD».

> Ссылки: `docs/planning/algorithm.md` (optional) → `your planning workflow docs` (фазы, ISC, output-формат),
> `docs/PRD-FORMAT.md` (frontmatter + body sections).

---

## Жизненный цикл (один PRD от планирования до закрытия swarm)

```
[ДО /OrchestratorSwarm]
  ┌──────────────────────────────────────────────────────────────┐
  │ OBSERVE → THINK → PLAN  (другие skill'ы или ручная Algorithm) │
  │   создан PRD: MEMORY/WORK/{slug}/PRD.md                       │
  │   - phase: plan (или build)                                   │
  │   - ## Criteria: ISC-1..ISC-N                                 │
  │   - ## Context, ## Decisions, ## Plan                         │
  └──────────────────────────────────────────────────────────────┘

[/OrchestratorSwarm]
  ┌──────────────────────────────────────────────────────────────┐
  │ BUILD (короткий)                                              │
  │   - Agent Mail preflight                                      │
  │   - pane inventory, role assignments, dispatch плана          │
  │   - Edit PRD: phase: build, updated: <ts>                     │
  │                                                               │
  │ EXECUTE  ← здесь живёт ВСЯ работа swarm                      │
  │   - looper ~3 мин: координация panes/beads/Mail               │
  │   - на каждый bead close → Edit PRD: [ ] → [x] для ISC,       │
  │     update progress: M/N в frontmatter                        │
  │   - Edit PRD: phase: execute, updated: <ts>                   │
  │                                                               │
  │ VERIFY  ← reality-check digest каждые ~16 мин                 │
  │   - sub-pass: сверить ISC vs реальное состояние main          │
  │   - Edit PRD: ## Verification — evidence по каждому ISC       │
  │   - НЕ меняй phase на verify в каждом digest — это sub-pass   │
  │                                                               │
  │ LEARN (когда backlog saturated или swarm заканчивается)       │
  │   - финальный VERIFY-проход по всем ISC                       │
  │   - Edit PRD: phase: verify → выполнить полный VERIFY         │
  │   - Edit PRD: phase: learn                                    │
  │   - Algorithm Q1–Q3 + append `docs/swarm-learnings/`     │
  │     algorithm-reflections.jsonl (см. Algorithm LEARN раздел)  │
  │   - Edit PRD: phase: complete                                 │
  └──────────────────────────────────────────────────────────────┘
```
**Ключевая идея:** swarm — это **долгая EXECUTE-фаза одного PRD** с периодическими sub-VERIFY проходами (reality-check). Полный переход в VERIFY и LEARN — только один раз, в самом конце.

---

## PRD Discovery (первое действие при /OrchestratorSwarm)

**Шаг 1.** Найти существующий PRD для текущей работы:

```bash
# Последний по mtime PRD в MEMORY/WORK/ репозитория
ls -t MEMORY/WORK/*/PRD.md 2>/dev/null | head -5
```
Если в репозитории нет `MEMORY/WORK/`, попробуй глобально:

```bash
ls -t ~/.claude/MEMORY/WORK/*/PRD.md 2>/dev/null | head -5
```
**Шаг 2.** Прочитать кандидат, проверить frontmatter:
- `task` — соответствует ли тому, что пользователь хочет крутить swarm'ом?
- `phase` — допустимы `plan`, `build`, `execute` (продолжаем). `complete` — это уже закрытый PRD, нельзя переиспользовать без `iteration: N+1`.
- `## Criteria` — должны быть ISC-чекбоксы (минимум столько, сколько требует effort tier).

**Шаг 3.** Подтвердить с пользователем **один раз** (если кандидат неоднозначен): «Найден PRD `<slug>`, task `<task>`, phase `<phase>`, ISC `M/N` закрыто. Крутим swarm под этот PRD?» — если очевидно один свежий PRD под тему, можно не спрашивать.

**Шаг 4.** Edit PRD frontmatter: `phase: build` → потом `phase: execute`, `updated: <ISO timestamp>`.

---

## Fallback: PRD не найден

Это **аномалия**, не норма. Что делать:

1. Сообщи пользователю: «PRD не найден в `MEMORY/WORK/`. Swarm должен крутить уже спланированную работу. Варианты: (a) ты сделаешь планирование отдельно через `/ce-plan` / `/prd` / Algorithm и вернёшься, (b) я сделаю минимальный stub PRD из текущего beads-backlog».
2. Если пользователь выбирает (b): создай минимальный PRD по `PRDFORMAT.md`:
   - `task` — короткая формулировка из beads-backlog (например, «Закрыть Stage 3 backlog»).
   - `effort: extended` (swarm работа обычно ≥extended).
   - `phase: execute` (сразу, потому что план = beads, OBSERVE/THINK/PLAN считаем выполненными в `br`).
   - `## Criteria` — ISC-чекбоксы по open/in_progress beads (BD-ID → одна строка ISC).
   - `## Context` — ссылка на beads-backlog как источник плана.
3. Не делай это автоматически без подтверждения пользователя.

---

## Mapping: bead close → ISC update

Когда worker закрывает bead, orchestrator **на ближайшем looper-проходе** проверяет, влияет ли это на ISC:

| Случай | Действие orchestrator |
|---|---|
| Bead напрямую покрывает один ISC (явный mapping в PRD или beads) | Edit PRD: `- [ ] ISC-X` → `- [x] ISC-X`, обновить `progress: M+1/N` |
| Bead покрывает часть ISC (множественные beads → один ISC) | Не меняй checkbox, пока **все** beads закрыты. Добавь evidence в `## Verification` |
| Bead не относится ни к одному ISC | Ничего не меняй в PRD. Если такое часто — флаг для пользователя: «PRD ISC и beads разошлись» |
| Bead закрыт, но ISC явно не выполнен (worker сделал не то) | Reviewer/QA найдёт в их фазе. Не помечай ISC `[x]` авансом |

**Правило:** `progress: M/N` в frontmatter — **источник истины для дашборда**. Обновляй сразу при close, не жди VERIFY.

---

## Reality-check digest = sub-VERIFY pass

Каждые ~16 мин (или ~6 looper-цикла) orchestrator делает digest по `RealityCheckDigest.md`. **Дополнительно**:

1. Прочитать текущий PRD (frontmatter + Criteria).
2. Сверить статус каждого ISC с реальностью (`git log main`, `br list --status closed`, capture panes).
3. Edit PRD `## Verification` — добавить evidence по новым ISC, прошедшим с прошлого digest:

```markdown
## Verification

### ISC-3: Hero section renders at 320px breakpoint
- Закрыто bead BD-42 (commit a3f5c2e)
- tmux capture-pane W3: визуальная проверка на http://127.0.0.1:3000 — pass

### ISC-7: Login fails with wrong password
- Закрыто bead BD-58 (commit b8d11a0)
- E2E test added: `tests/auth/login.spec.ts` — passes
```
4. **НЕ меняй `phase: verify` в frontmatter** — оставь `phase: execute`. VERIFY как полная фаза — только один раз в LEARN на закрытии swarm.
5. В digest для пользователя укажи: «PRD `<slug>` progress: M/N ISC закрыто; добавлено evidence для ISC-X, ISC-Y».

---

## LEARN: завершение swarm

Триггеры закрытия:
- Все ISC `[x]`, нет open beads, нет stalled work — swarm saturated.
- Пользователь говорит «закругляемся» / «stop swarm».
- Невозможно продвинуть остаток ISC без новой работы вне swarm.

**Процедура:**

1. Edit PRD: `phase: verify`, `updated: <ts>`.
2. Финальный VERIFY-проход:
   - Для каждого ISC, не помеченного `[x]` — честно прочитать состояние и либо пометить, либо оставить и описать почему не закрыт в `## Verification`.
   - **Capability invocation check:** swarm работал через panes/skills — это «капабилити». Если в PRD были выбраны конкретные skill'ы как capabilities, подтверди что они реально вызывались (worker dispatches это покрывают).
3. Edit PRD: `phase: learn`, `updated: <ts>`.
4. Algorithm LEARN Q1–Q3 (см. `docs/planning/algorithm.md` (optional) → LEARN section).
5. Append reflection JSONL (формат из Algorithm LEARN):

```bash
echo '{"timestamp":"<ISO>","effort_level":"<tier>","task_description":"<task из frontmatter>","criteria_count":<N>,"criteria_passed":<M>,"criteria_failed":<N-M>,"prd_id":"<slug>","implied_sentiment":<1-10>,"reflection_q1":"<что менять>","reflection_q2":"<что сделал бы умнее algorithm>","reflection_q3":"<какие capabilities не использовал>","within_budget":<true/false>}' >> docs/swarm-learnings/reflections.jsonl
```
6. Edit PRD: `phase: complete`, `updated: <ts>`.
7. Если был системный урок — `/ce-compound` (optional).
8. Сообщи пользователю: один абзац — что закрыто, что не закрыто, ключевой вывод.

**Если swarm заканчивается аварийно** (юзер прерывает, инфраструктурный коллапс) — попробуй пройти 1–4 в укороченном виде. PRD должен остаться в честном состоянии, не «зависшим в execute».

---

## Forward note: PAI 5.0

When your planning workflow adds new phases, update `GoalDispatch.md`:
- Перечитать `LATEST` и новый `<v>.md` при первом вызове.
- Mapping фаз и PRD format могут поменяться — этот документ должен быть пересмотрен.
- Если 5.0 вводит понятие **multi-phase concurrent execution** или **sub-PRD для подзадач**, пересмотреть «один PRD на работу» правило.

До тех пор живём по 3.7+.

---

## Связанное

- `SKILL.md` → Algorithm Integration (MANDATORY) — короткий якорь
- `OperatingProcedure.md` → First Actions включает PRD discovery
- **`LoopAlgorithmAnchor.md`** → слаб-напоминалка **в начале каждого** looper-тика (шаг 0); чеклисты EXECUTE / sub-VERIFY / LEARN
- `LoopPrompt.md` → шаг 0 + шаги 1–20; `/loop 3m … Algorithm EXECUTE tick`
- `RealityCheckDigest.md` → digest пишет в `## Verification`
- **`MemoryIntegration.md`** → session memory (optional; see `MemoryIntegration.md`) по фазам Algorithm (hindsight отключён)
