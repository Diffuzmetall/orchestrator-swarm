---
name: OrchestratorSwarm
description: >-
  EXECUTE-phase orchestrator for multi-pane CLI swarms (cc, cod, gmi) over Beads backlog to saturation.
  Stack: /ntm → /vibing-with-ntm → OrchestratorSwarm (looper ~3m, reality-check ~16m, worker/reviewer/QA).
  USE WHEN: orchestrator swarm, NTM swarm, beads backlog, looper, dispatch roles, marching orders,
  agent mail recovery, pane failover, reality check, goal-first, main-only no worktrees, AFK swarm,
  loop 3m, continue swarm execution. NOT FOR: BUILD preflight (_PLAN_TO_SWARM) or bare /ntm only.
  Codex: $OrchestratorSwarm; cc/gmi: /OrchestratorSwarm. Full triggers: ## Triggers (full) below.
---

# OrchestratorSwarm

Operate as the general orchestrator agent for a multi-pane CLI-agent swarm until Beads backlog saturation.

## Triggers (full)

Entry hierarchy: `/ntm` (tmux panes, send, spawn, robot monitoring) → `/vibing-with-ntm` (NTM + Agent Mail + Beads) → **OrchestratorSwarm** (looper ~3 min, reality-check ~16 min, role self-loops ~6–12 min, worker/reviewer/QA separation, pane failover, Agent Mail recovery, main-only, no worktrees). All tmux pane ops pass through `/ntm`.

**USE WHEN:** orchestrator swarm, NTM swarm operator, run agents over beads backlog, looper prompt, worker/reviewer/qa self-loop, coordinate cod cc gmi, ntm send busy pane, marching order inbox, looper file reservation overlap, pane dead, quota exhausted, rate limit, api key failover, swarm progress reality check, stage plan velocity, bv triage bottleneck, goal first not test theater, agent mail down recovery, idx_agents malformed, doctor reconstruct, orphan panes re-register, skill not found choose closest, do not mix workers reviewers QA, gmi slash skill syntax, workers keep pulling next beads, reread AGENTS.md, avoid sending prompt to self, main-only multi-agent backlog, session memory context-search cass-memory cm recall session archaeology before non-trivial bead/review/QA, ce-compound retain on recovery, PRD decisions verification on digest, ms suggest cwd, ms search topic robot, meta-skill picks local skill not find-skills, RulesRefresh every looper tick, start swarm, orchestrate agents, run backlog, loop swarm, dispatch roles, route skills, recover stalled work, agent mail ops, autonomous looper after dispatch, loop 3m continue without asking user. **Or** direct `/ntm` (spawn session, list panes, inspect tmux, tmux send) as foundational machinery only.

## Customization

**Before executing, check for user customizations at:**
`~/.config/orchestrator-swarm/`

If this directory exists, load and apply any `PREFERENCES.md`, configurations, or resources found there. These override default behavior. If the directory does not exist, proceed with skill defaults. See `docs/CUSTOMIZATION.md`.

## Mandatory Constraints

- Never invent the requested role mix or agent counts. The user provides counts/roles, not a manual pane-by-pane map; inspect NTM/tmux panes yourself and assign roles to available panes.
- Always run Agent Mail/MCP preflight before spawning the swarm.
- After Agent Mail restarts or MCP transients, verify pane registration parity and re-bootstrap orphan panes per `AgentMailRunbook.md`. Never store or paste bearer tokens in beads, PRs, or memory entries.
- All work happens in the current checkout on `main`.
- Never create or suggest git worktrees.
- Do not let `/ce-work`, `ntm`, or any other skill/tool switch into worktree mode.
- After every `ntm send`, submit with Enter for each pane.
- **Ground truth для панели:** не полагайся только на **NTM Activity / robot-snapshot** (в т.ч. состояние вроде `WAITING`): оно иногда показывает ожидание ввода, хотя агент уже в **Thinking**, пишет в терминал или гоняет инструменты — или наоборот. Каждый looper-проход и проверка после dispatch: **`tmux capture-pane`** (или эквивалент из твоего окружения) по целевым panes, последние ~10–20 строк. Сообщение **`Sent to pane` / доставка в input — не доказательство исполнения**: убедись по capture, что промпт ушёл и начался ход (нет «висящего» текста только в строке ввода без submit). Подробнее: `OperatingProcedure.md` → **NTM Activity vs tmux capture-pane**, `Gotchas.md`.
- **Deep pane reading (анти-«victory без evidence»):** счётчик `bv open=0` и `is_working: false` — это **shallow polling**, ровно паттерн который R1 reviewer'ы ловят как "closed without evidence". Перед reality-check digest, перед заявлением "victory" пользователю, и при любом подозрительно быстром закрытии bead (<2 мин) или FAIL-сигналах в буфере (`absent`, `MISSING`, `SKIP`, `ECONNREFUSED`, `fallback`, `TODO`) — **читай recap-блоки panes** (NATIVE/MINIMAL mode header c **🗣️ agent recap** summary, `🔧 CHANGE`, `✅ VERIFY`), сверь с `br show <id> --json` close reason, и **физически проверь обещанные артефакты** (`test -f`, `jq -e`, `git log origin/main..HEAD`). Triangulate три слоя — recap / close reason / диск — не один. Полный протокол с red-flag токенами и шагами medium→deep: `PaneRecapReading.md`.
- The general orchestrator sends role prompts with explicit skill bundles; do not assume workers/reviewers/QA agents will choose the right skills alone.
- Dispatch bodies must list **literal first-invocation lines** (`/skill` or `$skill`, one per line, in order). Prose-only "Skills: …" lists are insufficient — they are often treated as hints and never invoked (Skill calls stay at 0).
- **Fleet parity:** Proving literal lines on one pane is not enough. Re-dispatch **every** swarm pane (same role class) with the same literal-line style when you change prompt format; mixed old/new prompts explain "one pane N skill calls, others 0".
- **Goal-first:** advance the bead to **done+correct**; use **`bv --robot-triage`** / **`bv --robot-next`** and **`/beads-bv`** (**`$beads-bv`** on Codex) to find graph **bottlenecks**. Add **enough** tests for regressions/contracts/critical paths — **not** test theater or suites unrelated to the bead’s risk.
- Skill syntax: `cc` and `gmi` use `/skill-name`; `cod` uses `$skill-name`.
- **cc/cod/gmi + комплексный bead:** dispatch включает **`/goal`** с измеримым телом (шаблон: **`GoalDispatch.md`**), не только prose «Цель: …». Для cc и cod — `/goal` (slash), не `$goal`.
- Skill syntax: `cc` and `gmi` use `/skill-name`; `cod` uses `$skill-name`.
- **cc + комплексный bead / измеримая цель:** если pane — **`cc`** (Claude Code), и задача не тривиальная, dispatch должен включать **`/goal`** (slash-команда cc/cod/gmi) с критерийно-измеримым телом (ISC-style; см. **`GoalDispatch.md`**), шаблон и порядок вызовов: **`GoalDispatch.md`** и **`RolePrompts.md`** (не заменять литеральным блоком только prose «Цель: …» в тексте).
- Keep worker, reviewer, and QA roles distinct. Do not send a worker prompt to a reviewer/QA pane or a review/QA prompt to a worker pane unless the orchestrator explicitly reassigns that pane first.
- Workers do not stop after a bead: after close + Mail poll + commit, they claim the next ready/open bead and refresh the skill bundle for that new bead — **no terminal idle** at empty prompt (see `RolePrompts.md`, `Gotchas.md`).
- The loop refreshes repo-local rules and its own instructions by rereading **project + global `AGENTS.md` and `CLAUDE.md`** on a fixed cadence — см. **`RulesRefresh.md`**. Также: `/OrchestratorSwarm` / this skill, OperatingProcedure, relevant context files.
- Never send worker/reviewer/QA role prompts to the orchestrator's own pane. Identify and exclude the orchestrator pane from `ntm send` target lists.
- Every pane must actively use Agent Mail: check inbox/reservations regularly, acknowledge `ack_required`, reserve files before editing, and communicate blockers/conflicts through mail.
- Keep coordination high-signal: Agent Mail is for ownership, blockers, conflicts, handoffs, findings, and ack-required decisions, not redundant status chatter or conversational threads.
- **Rules refresh (AGENTS + CLAUDE, global + project) — mandatory, all roles.** Orchestrator: **каждый looper-тик** — проектные `AGENTS.md` + `CLAUDE.md`; **каждый ~3-й тик** и digest — + глобальные (см. **`RulesRefresh.md`** и **`docs/ECOSYSTEM.md`**). Worker/reviewer/QA: **каждый self-loop** — полный набор (что существует). Repo rules **перебивают** generic skill advice.
- **Memory:** core recall via git, `docs/solutions/`, PRD — см. **`MemoryIntegration.md`**. Если установлен Flywheel stack — добавь **`/cass-memory`**, **`/context-search`**, `cm context` по триггерам там же; полная PAI-карта: **`optional-extensions/MemoryIntegration-PAI.md`**.
- **Local skill discovery via `ms` (if installed):** для нетривиального bead — `ms suggest --cwd <repo>` и `ms search "<topic>" --robot` после memory recall. **Не путать с `/find-skills`**. Если `ms` нашёл локальный скилл — вызывай буквально (`<prefix>skill-name`).
- If the exact desired skill is missing or `ms search` returns nothing, choose the closest semantically appropriate skill from `SkillRouting.md` or a general-purpose workflow and continue.
- **Использовать недоиспользуемую NTM-поверхность** там, где это снижает ручную работу оркестратора: `ntm pipeline` вместо ручного looper-а для стабильных flow, `ntm template`/`recipes`/`session-templates` для повторяющихся marching orders, `ntm quota` + `ntm rotate` при rate-limit (до перехода к Mail recovery), `ntm --robot-causality` для пост-морт и reality-check digest. Детали и точки внедрения по файлам — `NTMSurfaceGaps.md`.
- **Автономный looper после dispatch — обязателен, без вопросов пользователю.** Сразу после fleet dispatch: `/loop 3m /OrchestratorSwarm continue swarm execution — Algorithm EXECUTE tick (read LoopAlgorithmAnchor.md first)`. Каждый тик: **`LoopAlgorithmAnchor.md`** → `LoopPrompt.md`. **Запрещено:** спрашивать «запустить looper?» между тиками.
- **AFK: не бесконечный loop.** Если оператор AFK (LaunchAFK / нет ответов): вести `afk_stall_loops`; при **≥6** тиков без прогресса или **невосстановимом блокере** после 1 recovery — **`/loop stop`**, Mail «AFK PAUSE», **`docs/swarm-afk-exit-handoff.md`** по **`AFKExitHandoff.md`**. Не ждать человека между тиками. AFK exit ≠ LEARN (PRD остаётся `execute` до resume).
- **Algorithm Integration (MANDATORY):** `/OrchestratorSwarm` — **исполнитель EXECUTE-фазы существующего PRD**. Перед спавном найди PRD в `docs/work/` или `MEMORY/WORK/` (`AlgorithmIntegration.md`). **Не создавай второй PRD.** Каждый bead close по ISC → Edit PRD; reality-check → `## Verification`; закрытие swarm → VERIFY → LEARN → `phase: complete`. Формат: **`docs/PRD-FORMAT.md`**.

- Every dispatched worker/reviewer/QA prompt must tell the pane to run its **role self-loop** (`WorkerLoopPrompt.md` ~6 min, `ReviewerLoopPrompt.md` / `QALoopPrompt.md` ~6 min) with correct **`/` vs `$`** syntax (`SKILL.md` → Context Files).

| Workflow | Trigger | File |
| --- | --- | --- |
| **NTM Base Machinery** | "ntm", "spawn session", "list panes", "tmux", "ntm send", "inspect panes" | `/ntm` skill — core entry point |
| **VibingWithNTM** | "vibing", "marching orders", "coordination", "agent mail" | `/vibing-with-ntm` skill — NTM + Mail + Beads |
| **RunSwarm** | "start swarm", "orchestrate agents", "run backlog" | `OperatingProcedure.md` via **OrchestratorSwarm** |
| **LoopSwarm** | "loop", "looper", "keep swarm moving", "autonomous looper", "/loop 3m" | `LoopPrompt.md` via **OrchestratorSwarm** |
| **AutonomousLooper** | после dispatch, "continue swarm execution", "автономный looper", "loop 3m" | `LoopPrompt.md` + **`LoopAlgorithmAnchor.md`** (шаг 0 каждого тика) |
| **AFKExit** | "AFK", "ухожу спать", "нет ответа", "stop infinite loop", "stall handoff", "swarm-afk-exit" | **`AFKExitHandoff.md`** — стоп looper + `docs/swarm-afk-exit-handoff.md` |
| **AlgorithmLoopAnchor** | "мы в алгоритме", "PRD sync", "ISC progress", "не забыть PRD" | `LoopAlgorithmAnchor.md` — чеклист EXECUTE / sub-VERIFY / LEARN на каждом тике |
| **RoleSelfLoop** | "worker loop", "reviewer loop", "qa self-loop", "/worker-self-loop" | `WorkerLoopPrompt.md`, `ReviewerLoopPrompt.md`, `QALoopPrompt.md` via **OrchestratorSwarm** |
| **RealityCheck** | "how are we doing vs plan", "progress digest", "stage status", "~16 min summary" | `RealityCheckDigest.md` via **OrchestratorSwarm** |
| **PaneRecapReading** | "что pane реально сделал", "deep read panes", "agent recap summary", "victory без evidence", "проверь artifacts на диске", "closed without evidence", "shallow polling" | `PaneRecapReading.md` via **OrchestratorSwarm** |
| **DispatchRoles** | "write marching orders", "send role prompt" | `RolePrompts.md` via **OrchestratorSwarm** |
| **RouteSkills** | "which skill for this bead/review/QA" | `SkillRouting.md` via **OrchestratorSwarm** |
| **RecoverStalledWork** | "debug stalled agents/beads" | `OperatingProcedure.md` via **OrchestratorSwarm** |
| **AgentMailOps** | "agent mail broken", "restart mail", "mcp agent mail", "orphan panes", "re-register" | `AgentMailRunbook.md` via **OrchestratorSwarm** |
| **NTMSurfaceGaps** | "ntm pipeline", "ntm template", "ntm recipes", "ntm rotate", "ntm quota", "ntm causality", "underused ntm", "недоиспользуемые команды ntm" | `NTMSurfaceGaps.md` via **OrchestratorSwarm** |
| **AlgorithmIntegration** | "PRD", "Algorithm phase", "execute phase", "MEMORY/WORK", "ISC", "phase complete", "swarm finishes PRD" | `AlgorithmIntegration.md` via **OrchestratorSwarm** |
| **MemoryIntegration** | "session memory", "when to recall", "ce-compound", "cass cm context", "context-search", "context search", "prior work", "session archaeology", "docs/solutions", "algorithm learn memory" | `MemoryIntegration.md` via **OrchestratorSwarm** |
| **RulesRefresh** | "reread AGENTS", "refresh CLAUDE", "rules drift", "global AGENTS", "project CLAUDE", "правила в памяти", "перечитать AGENTS" | `RulesRefresh.md` via **OrchestratorSwarm** |
| **ContextRecall** | "find prior work", "what did we do before", "load context on", "context-search before bead", "remember past session", "контекст по", "что уже делали" | `/context-search` + **`MemoryIntegration.md`** → «Пара recall» (paired with `/cass-memory`) |

## Entry Point Hierarchy

`/ntm` — это фундамент, но есть три уровня абстракции. Выбирай нужный:

| Уровень | Скилл | Когда использовать |
|---|---|---|
| **1. Машинерия** | `/ntm` | Сессии, tmux panes, send, spawn, robot-мониторинг. Чистая инфраструктура безcoordination overhead. |
| **2. Координация** | `/vibing-with-ntm` | NTM + Agent Mail + Beads. Работа с очередями, marching orders, review loops. Средний уровень для swarm без полного orchestrator. |
| **3. Оркестрация** | `/OrchestratorSwarm` | Полный orchestrator: looper ~3 мин, reality-check ~16 мин, role separation (worker/reviewer/QA), role self-loops (~6–12 мин), pane failover, Agent Mail recovery, main-only policy. |

### Как они связаны

```
/ntm (base machinery)
   └─ /vibing-with-ntm (NTM + Mail + Beads)
          └─ /OrchestratorSwarm (full orchestrator)
```
- **`/ntm`** вызывается напрямую когда нужно: inspect panes, send short messages, spawn/attach/kill sessions, check robot status
- **`/vibing-with-ntm`** — когда есть beads backlog и нужны marching orders, но нет сложного multi-role choreography
- **`/OrchestratorSwarm`** — когда нужен полноценный swarm с worker/reviewer/QA, looper discipline и periodic digest

### `/ntm` как primary entry

`/OrchestratorSwarm` **не работает без `/ntm`** — он внутри вызывает все NTM-операции. Поэтому `/ntm` должен быть явно упомянут как "главный скилл" в описании и в trigger list.

Все trigger'ы OrchestratorSwarm, которые включают tmux pane management, session dispatch или robot monitoring — это точки входа в `/ntm`.

## Quick Start

1. Read repo `AGENTS.md`, `CLAUDE.md`, and `README.md`.
2. Read `OperatingProcedure.md`, `AlgorithmIntegration.md`, and **`MemoryIntegration.md`**.
3. **PRD discovery (MANDATORY первый шаг по работе):** `ls -t MEMORY/WORK/*/PRD.md 2>/dev/null | head -5`. Найди существующий PRD, проверь frontmatter (`task`, `phase` ∈ {plan, build, execute}, `## Criteria` с ISC). Если PRD нет — спроси пользователя (fallback в `AlgorithmIntegration.md`); **не создавай второй PRD авто**. Edit PRD: `phase: build`, `updated: <ts>`.
4. Run Agent Mail preflight.
5. **Memory recall перед спавном swarm** (orchestrator): `cm context "orchestrate NTM swarm <repo>" --json`; **`/context-search "<repo> swarm agent-mail ntm gotchas"`** — поднять прошлые incident-паттерны и PRD/WORK по проекту. См. **`MemoryIntegration.md`** → «Пара recall».
6. Get the user's requested role mix/counts, for example "5 workers, 2 reviewers, 1 QA".
7. Inspect current NTM/tmux panes and build the pane map yourself.
8. Spawn or reuse panes via **`/ntm`** (core session management) — это главный скилл для всех tmux-операций.
9. Dispatch each pane with a role prompt from `RolePrompts.md` (**включая строку self-loop** + файл и интервал для роли + **`/cass-memory` в ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ** + при триггерах **`/context-search`** literal line + bash `cm context` + `ms suggest --cwd <repo>`). Триггеры context-search: **`MemoryIntegration.md`**.
10. **Перед стартом looper:** Edit PRD: `phase: execute`, `updated: <ts>`. С этого момента весь looper крутится **внутри EXECUTE-фазы этого PRD**.
11. **Сразу после dispatch (обязательно, без вопроса пользователю):** на orchestrator pane выполни литерально `/loop 3m /OrchestratorSwarm continue swarm execution — Algorithm EXECUTE tick (read LoopAlgorithmAnchor.md first)` + Enter. Каждый тик: **шаг 0** `LoopAlgorithmAnchor.md` → `LoopPrompt.md` (шаги 1–20); reality-check ~16 мин = sub-VERIFY в PRD (`AlgorithmIntegration.md`, `RealityCheckDigest.md`). Не спрашивай разрешения на loop.
12. Пока loop активен, каждый Cycle держит **Algorithm EXECUTE** (PRD `phase: execute`, bead→ISC sync, `progress: M/N`) до saturation; workers/reviewers/QA параллельно гоняют **`WorkerLoopPrompt.md`** / **`ReviewerLoopPrompt.md`** / **`QALoopPrompt.md`**. **В каждом проходе** — **`tmux capture-pane`** по swarm-panes, не только NTM Activity. **На каждый bead close, покрывающий ISC,** Edit PRD: `[ ]` → `[x]`, `progress: M/N`. **На каждый reality-check digest** — добавь evidence в `## Verification` (см. `AlgorithmIntegration.md`).
13. После каждого recovery action (Mail repair/reconstruct, role failover, force-reassign stale bead, restart dead pane) — Edit PRD `## Decisions` (incident + fix, без секретов); при системном уроке — `/ce-compound`.
14. **Закрытие swarm (LEARN):** когда backlog saturated / пользователь говорит стоп / нельзя двигаться дальше — `phase: verify` → финальный VERIFY → `phase: learn` → Algorithm Q1–Q3 + append `docs/swarm-learnings/reflections.jsonl` → `phase: complete`. Процедура: `AlgorithmIntegration.md` → **LEARN: завершение swarm**; карта памяти: `MemoryIntegration.md`.

## When to Use Which Entry Point

Используй триггеры ниже чтобы выбрать правильный entry point:

| Фраза пользователя | Скилл | Почему |
|---|---|---|
| "ntm" / "создай сессию" / "spawn" / "list panes" / "inspect tmux" / "ntm send" | `/ntm` | Машинерия tmux — напрямую управляет panes, сессиями, send. Без orchestration overhead. |
| "vibing" / "marching orders" / "work through beads" / "coordination" / "agent mail" | `/vibing-with-ntm` | NTM + Agent Mail + Beads. Когда есть backlog и нужно координировать агентов, но без полного orchestrator loop. |
| "swarm" / "orchestrate agents" / "run backlog" / "5 workers 2 reviewers" / "looper" / "keep swarm moving" / "worker loop" / "reviewer loop" / "reality check" / "stage status" / "swarm progress" | `/OrchestratorSwarm` | Полный orchestrator: role separation, looper ~3 мин, reality-check ~16 мин, role self-loops (~6–12 мин), pane failover, main-only, no worktrees. |
| "start swarm" / "orchestrate agents" / "run backlog" | `OperatingProcedure.md` (via OrchestratorSwarm) | Полная процедура от preflight до looper. |
| "loop" / "looper" / "keep swarm moving" | `LoopPrompt.md` (via OrchestratorSwarm) | Короткий looper prompt для поддержания swarm alive. |
| "worker loop" / "reviewer loop" / "qa self-loop" / "/worker-self-loop" | `WorkerLoopPrompt.md`, `ReviewerLoopPrompt.md`, `QALoopPrompt.md` (via OrchestratorSwarm) | Role self-loop для каждого pane. |
| "how are we doing vs plan" / "progress digest" / "stage status" / "~16 min summary" | `RealityCheckDigest.md` (via OrchestratorSwarm) | Периодический digest сравнения progress vs plan. |
| "write marching orders" / "send role prompt" | `RolePrompts.md` (via OrchestratorSwarm) | Шаблоны role prompts для dispatch. |
| "which skill for this bead/review/QA" | `SkillRouting.md` (via OrchestratorSwarm) | Матрица routing скиллов по bead type, risk, QA flow. |
| "debug stalled agents/beads" / "agent mail broken" / "restart mail" / "orphan panes" / "re-register" | `OperatingProcedure.md` / `AgentMailRunbook.md` (via OrchestratorSwarm) | Recovery procedures. |

**`/ntm` — главный скилл:** он лежит в основе `/vibing-with-ntm` и `/OrchestratorSwarm`. Все tmux-pane операции проходят через `/ntm`. Поэтому `/ntm` должен быть первым в skill hierarchy и вызываться напрямую когда нужна чистая machinery без orchestration.

## Context Files

- **Algorithm Integration (MANDATORY first read):** `AlgorithmIntegration.md` — PRD discovery, EXECUTE-фаза lifecycle, mapping bead→ISC, reality-check как sub-VERIFY, LEARN на закрытии swarm
- **Algorithm loop anchor (каждый тик):** `LoopAlgorithmAnchor.md` — слаб-напоминалка: мы в EXECUTE, что отметить в PRD
- Full SOP: `OperatingProcedure.md`
- Short looper prompt: `LoopPrompt.md` (шаг 0 → anchor, шаги 1–20 → координация)
- Periodic plan vs reality summary: `RealityCheckDigest.md`
- **Deep pane reading (recap + 🗣️ agent recap + verify artifacts):** `PaneRecapReading.md` — обязательно перед reality-check digest, перед "victory", и при FAIL-сигналах в буфере; ловит "closed without evidence" до того как R1 reviewer откроет defect
- Worker self-loop (~12 min): `WorkerLoopPrompt.md`
- Reviewer self-loop (~6 min): `ReviewerLoopPrompt.md`
- QA self-loop (~6 min): `QALoopPrompt.md`
- Role prompt templates: `RolePrompts.md`
- Skill routing matrix: `SkillRouting.md`
- Gotchas and validation notes: `Gotchas.md`
- Agent Mail incidents, health, recovery, orphan panes: `AgentMailRunbook.md`
- Goal dispatch for all slash-based agents (cc/cod/gmi): `GoalDispatch.md`
- Underused NTM surface (pipeline, templates, rotate/quota, causality) — что включать в looper/recovery: `NTMSurfaceGaps.md`
- **Memory by algorithm phase (session memory (optional; see `MemoryIntegration.md`) + ContextSearch, no hindsight):** `MemoryIntegration.md`
- **Rules refresh (AGENTS + CLAUDE):** `RulesRefresh.md` via **OrchestratorSwarm**
- **Context search skill (upstream):** `~/.claude/skills/ContextSearch/SKILL.md` — `/context-search`, `/cs`

## Examples

**Example 1: Start a backlog swarm**
```text
User: "Use OrchestratorSwarm: 5 workers, 2 reviewers, 1 QA."
-> Load OperatingProcedure.md
-> Run Agent Mail preflight
-> Inspect NTM/tmux panes and build the pane map
-> Spawn/reuse and dispatch panes with role prompts
-> Immediately (no ask): /loop 3m … Algorithm EXECUTE tick (LoopAlgorithmAnchor.md first)
```
**Example 2: Keep an existing swarm moving**
```text
User: "Run the OrchestratorSwarm loop."
-> Load LoopPrompt.md
-> Inspect panes, Agent Mail, and Beads
-> Reassign idle/stalled work
```
**Example 3: Worker runs their own loop**
```text
User: "Run worker self-loop."
-> Open OrchestratorSwarm `WorkerLoopPrompt.md`
-> Follow checklist; cc/gmi use `/`, cod uses `$`
-> Typical spacing ~12 minutes between runs
```
