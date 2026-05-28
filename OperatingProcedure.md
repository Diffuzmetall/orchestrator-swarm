# Operating Procedure

Use this workflow when acting as the general orchestrator for an NTM swarm over a Beads backlog.

## Mission

You are the main orchestrator agent. Your job is to raise, coordinate, and keep alive a swarm of CLI agents (`cod`, `cc`, `gmi`, and others) until backlog saturation.

The user provides the requested role mix and counts separately, for example "5 workers, 2 reviewers, 1 QA". Do not invent counts, agent types, or roles. Do not require the user to provide a manual pane-by-pane map; inspect the current NTM/tmux session yourself and assign roles to available panes.

## First Actions

1. Read the target repo's `AGENTS.md`, `CLAUDE.md`, and `README.md`.
2. Read **global** rules if present: `$GLOBAL_AGENTS.md` (see `docs/ECOSYSTEM.md`), `~/.claude/CLAUDE.md` (see **`RulesRefresh.md`**).
3. Read **`MemoryIntegration.md`** (session memory (optional; see `MemoryIntegration.md`) по фазам Algorithm).
4. **Rules refresh during swarm:** orchestrator — **every looper tick** (project) + **every ~3rd tick / digest** (global); all roles — **every self-loop** (full set). **`RulesRefresh.md`**.
5. Apply repo-local rules over generic NTM or skill advice.
6. Enforce main-only operation: current checkout on `main`, no worktrees.
7. Run Agent Mail/MCP preflight before spawning or dispatching the swarm.
8. **Memory recall перед спавном:** `cm context "orchestrate NTM swarm <repo>" --json`; при необходимости `/context-search "<repo> swarm gotchas"`. См. **`MemoryIntegration.md`** и раздел **Memory (session memory (optional; see `MemoryIntegration.md`))** ниже.

## Main-Only Policy

All work happens in the current checkout on `main`.

- Never create git worktrees.
- Never propose worktrees as an option.
- Do not use `ce-worktree`.
- If `/ce-work`, `ntm`, or another skill suggests worktree mode, override it and continue in the current checkout on `main`.
- Never use `master` in commands, code, or docs.

## Memory (session memory (optional; see `MemoryIntegration.md`)) — Mandatory At Every Level

**Hindsight отключён** — не вызывать `/hindsight`, `$hindsight`, `hindsight memory …`.

Память не «по желанию» — она применяется на **каждом** уровне swarm. Канон: `optional-extensions/MemoryIntegration-PAI.md`. Полная карта по фазам Algorithm и ролям: **`MemoryIntegration.md`**.

**Slash для ролей:** `/cass-memory` (cc/gmi) или `$cass-memory` (cod) — в ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ **сразу после** `/agent-mail`. Затем bash: `cm context "<task>" --json`.

| Когда (триггер) | READ (recall) | WRITE (retain) |
| --- | --- | --- |
| **Orchestrator: перед сложным dispatch / role failover / Mail recovery** | `cm context "orchestrate swarm <blocker>" --json`; `/context-search "<проект + симптом>"`; `cass search "…" --json` при incident | Edit PRD `## Decisions`; Mail (без секретов) |
| **Orchestrator: reality-check digest (~16 мин)** | Read PRD Criteria + Verification; git; panes | Edit PRD `## Verification` — evidence |
| **Worker: перед нетривиальным bead** | `cm context "<bead>" --json`; `rg "<topic>" docs/solutions/`; при незнакомой подсистеме — `/context-search` | Edit PRD `## Decisions`; `/ce-compound` если урок командный |
| **Reviewer: перед review** | `cm context "code review <domain>" --json`; `docs/solutions/` grep | `/ce-compound` при системном defect class |
| **QA: перед flow** | `cm context "<flow> QA" --json`; `cass search "<flow> flaky" --json` | PRD Verification evidence; `/ce-compound` для repro recipe |
| **LEARN (закрытие swarm)** | Read PRD итог | Algorithm Q1–Q3; `algorithm-reflections.jsonl`; optional `/ce-compound` |

**Связанные инструменты:**

| Слой | Tool | Когда |
| --- | --- | --- |
| Широкий контекст (PRD, WORK, git) | `/context-search <topic>` | Незнакомая тема, swarm setup, incident |
| Past agent sessions | `/cass` / `cass search … --json` | «Кто что пробовал», session archaeology |
| Procedural playbooks | `cm context "<task>" --json`, `/cass-memory` | **Перед каждой** нетривиальной задачей |
| Repo team learnings | `docs/solutions/`, `/ce-compound` | Durable fix/pattern для всей команды |
| Algorithm state | Edit `MEMORY/WORK/.../PRD.md` | Decisions, Verification, ISC, phase |
| LEARN reflection | append `docs/swarm-learnings/reflections.jsonl` | Один раз при закрытии swarm |

**Fail open:** если `/context-search`, `/cass`, `/cass-memory`, `cm`, или `ms` недоступны — сообщи один раз в Mail и продолжай по `SkillRouting.md`. Память не блокирует swarm, но при доступности **не пропускай** `cm context` на нетривиальных beads.

**Не пиши вручную** в `$MEMORY_ROOT/LEARNING/` (optional; see `optional-extensions/MemoryIntegration-PAI.md`) — hooks делают это автоматически.

## Local Skill Discovery (meta-skill / ms)

Каждый dispatch для нового или нетривиального bead/review/QA flow **обязан** включать шаг локального подбора скилла через `ms` CLI **до** ухода в основной workflow.

| Команда | Когда |
| --- | --- |
| `ms suggest --cwd <абсолютный путь репозитория>` | Дефолтный шаг: «что вообще релевантно для этой кодовой базы» |
| `ms search "<bead/review/QA topic>" --robot` | Точечный поиск под конкретную тему |
| `ms show <name>` | Просмотр SKILL.md без загрузки |
| `ms load <name>` | Загрузить инструкции скилла в контекст |

**Не путать:** `/find-skills` ставит **внешние** скиллы из публичного реестра. Для **локально установленных** скиллов нужен `ms`. Если оркестратор по ошибке ссылается на `/find-skills` в контексте local discovery — это баг.

`ms` — это CLI, поэтому в ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ (где только литеральные slash) он не идёт. Он идёт как **обязательный bash-шаг в теле marching order** сразу после memory recall, до основной работы. См. `RolePrompts.md` → шаблоны.

## Agent Mail Preflight

Do not spawn the swarm until this is acceptable.

Run:

```bash
am doctor check --verbose
```
If `am` is unavailable, use the project-documented fallback, for example:

```bash
uv run python -m mcp_agent_mail.cli doctor check --verbose
```
If coordination-blocking errors appear:

```bash
am doctor repair --dry-run
am doctor repair --yes
am doctor check --verbose
```
If `doctor check` still reports **malformed** index / **`idx_agents_*`** issues, or damage after disk/OS restarts: **`doctor repair` is not always enough**. **Stop the Agent Mail service first**, then optionally `am doctor reconstruct --dry-run`, then `am doctor reconstruct --yes`, restart the daemon, and run `am doctor check --verbose` again. Use `uv run python -m mcp_agent_mail.cli doctor reconstruct …` if `am` is not on `PATH`. Details: `AgentMailRunbook.md` → **Index reconstruct**.

Confirm MCP Agent Mail responds. If repair requires user action (tokens, network, rights), report the blocker once and wait unless the user explicitly authorizes fail-open operation without mail.

Quick sanity between `doctor` and MCP:

```bash
curl -sS http://127.0.0.1:8765/health
```
If this fails, fix the daemon first (`am`, installer, or service used in your environment) before blaming MCP config.

## Agent Mail Incidents And Pane Re-Registration

Agent Mail is a **control plane**. A server restart, port conflict, token mismatch, or brief MCP disconnect creates a **transient window** where panes keep typing but **lose identity, inbox, and reservations**.

**Always:**

1. Restore `/health` + `doctor check` (repair if needed; if **malformed** / **`idx_agents_*`**: stop daemon → `doctor reconstruct` per `AgentMailRunbook.md`). Full ladder: `AgentMailRunbook.md`.
2. Assume **every pane** must re-run `/agent-mail` bootstrap (`macro_start_session` with the repo `human_key`) after a confirmed outage or PID change — not only the orchestrator.
3. **Reconcile counts**: NTM/tmux panes (by role) vs registered agents for that project. Orphan panes = coordination-unhealthy until bootstrapped.
4. Dispatch **short, high-signal** `ntm send` to lost panes: “Server healthy — run `macro_start_session` for `<repo path>` now.”
5. **Never** paste bearer tokens, full MCP headers, or secrets into beads, PRs, or Cass/CM/PRD/Mail. Record symptoms and fixes only.

Deep symptom table, recovery order, and memory guidance: `AgentMailRunbook.md` (also aligns with `~/.claude/skills/agent-mail/references/RECOVERY.md`).

## Agent Mail Heartbeat

Every pane must actively use Agent Mail, not just the orchestrator.

Each worker, reviewer, and QA pane must:

1. Register/check identity at session start if the repo expects Agent Mail.
2. Check inbox before starting a bead/review/QA flow.
3. Check inbox after major milestones: claim, first edit, test failure, close, commit, review finding.
4. Check inbox at least every looper cycle during long-running work.
5. Acknowledge `ack_required` messages promptly.
6. Reserve files before editing when file reservations are available.
7. Release/update reservations when switching tasks or stopping work.
8. Use Agent Mail for blockers, overlap, handoff notes, and conflict resolution.

The looper should treat a pane that ignores Agent Mail as unhealthy. First remind it to check mail and reservations; if it keeps ignoring mail, pause new assignments to that pane until it complies.

Keep coordination efficient. Agent Mail is for actionable coordination, not chatter. Send messages when they affect ownership, blocking, handoff, review, conflict resolution, or another pane's next action. Avoid redundant "still working", vague FYIs, and conversational threads that do not change work routing.

## Spawn

Use:

- `/ntm` for session orchestration.
- `/vibing-with-ntm` for NTM + Agent Mail + Beads/BV swarm operations.
- `/agent-mail` for reservations, inbox, file overlap, and conflict handling.
- `/agent-fungibility-philosophy` for replacing dead agents or redistributing roles.

Rules:

1. Wait for explicit role counts from the user, not a manual pane map.
2. Inspect current panes yourself with NTM/tmux robot/non-interactive commands.
3. Build the pane map yourself: pane id, CLI type (`cc`, `cod`, `gmi`, other), assigned role, current state.
4. Identify the orchestrator's own pane and mark it as `orchestrator`.
5. Exclude the orchestrator pane from worker/reviewer/QA target lists.
6. If there are not enough suitable non-orchestrator panes for the requested counts, ask whether to spawn more or reduce counts.
7. After every `ntm send`, submit with Enter for that pane.
8. Track each pane's type, role, bead, last action, and last activity time.
9. Never use `ntm --worktrees` or `ntm worktrees`.
10. Every dispatched prompt body must include **ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ**: literal lines starting with `/skill` (`cc`/`gmi`) or `$skill` (`cod`), in execution order. Do **not** replace with an inline "Скиллы: …" hint paragraph — that correlates with **Skill calls = 0** in session telemetry and skipped `/agent-mail`.
11. For **`cod`** workers on **non-trivial** beads (multi-step, unclear done-ness, high regression risk), include **`/goal`** (Codex slash command) with a **measurable** spec after `$agent-mail` — template and rationale in **`GoalDispatch.md`** (align criteria with **ISC-style** measurable criteria under `ISC-style criteria in `GoalDispatch.md`). Skip **`/goal`** only for obvious single-criterion micro-beads.

Useful inspection commands depend on the active setup. Prefer robot/non-interactive forms, for example:

```bash
ntm list
ntm status <project>
ntm --robot-snapshot
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_current_path} #{pane_title}'
```
The user should only need to say the desired composition, for example:

```text
5 workers, 2 reviewers, 1 QA
```
The orchestrator maps that onto actual panes.

## NTM `--robot-send` + `--msg-file` (preferred batch dispatch)

For **initial fleet dispatch** or **full marching orders** to specific panes, use **`ntm --robot-send`** with a **file**, not a shell-quoted string and not `ntm --robot-send` without the session name.

**SESSION must be first** (basename, e.g. `yandex-ads-mcp-hub`):

```bash
PROJECT=yandex-ads-mcp-hub
ntm --robot-send="$PROJECT" --panes=2 --msg-file=/tmp/swarm/p2_qa.md --delay-ms=800
# equivalent:
ntm --robot-send "$PROJECT" --panes=3 --msg-file=docs/swarm-prompts/p3_worker.md
```
**Invalid** (NTM treats `--panes=2` as the session name):

```bash
ntm --robot-send --panes=2 --msg-file=/tmp/swarm/p2_qa.md
# → Error: invalid session name: "--panes=2"
```
Prompt file rules (see also `~/.claude/skills/_PLAN_TO_SWARM/RobotSendDispatch.md`):

- No `$model`, `/model`, or `gpt-5.5-high` in the file — models come from spawn + `~/.codex/config.toml`.
- **Literal first lines in the pane:** `/agent-mail` then `/cass-memory` (cc/gmi) or `$…` (cod) — agent must **execute** `/agent-mail` before bash `macro_start_session(human_key=…)`.
- Verify target pane shows agent UI: `tmux capture-pane -t "$PROJECT:1.N" -p | tail -12` — not zsh, not `command not found`.

Dry-run: `ntm --robot-send="$PROJECT" --panes=N --msg-file=… --dry-run`

Still apply **idle gate** below when re-dispatching mid-turn; use **Agent Mail** if pane is busy.

## NTM Send, Busy Panes, And Input Stuck-Text

`ntm send` **injects text into the pane’s input**, then you submit with Enter. That is **not** a reliable queue when the CLI is mid-turn:

| Pane state | Risk |
| --- | --- |
| Idle (empty `❯`, waiting for user) | Usually OK — text submits as intended |
| Thinking / tool-use / subprocess | Text sits **unsubmitted** or races the cursor; prompts **truncate**, **interleave** with paste buffers, or **vanish** after Esc |
| Compacting conversation | Same — input is a bad mailbox |
| Another `ntm send` while paste in flight | Garbling, “[Pasted text #N]”, lost prompts |

**Do not blindly timer-dispatch** fat multi-line prompts (marching orders with literal `/skill` lines) into workers just because the looper tick fired.

### NTM Activity vs tmux capture-pane

Summaries like **`ntm` activity / robot-snapshot** are useful for a quick scan but **can disagree** with what the pane is really doing. Typical failure modes:

| Symptom | What capture-pane often shows instead |
| --- | --- |
| Activity = `WAITING` / idle | Agent mid-**Thinking**, tool subprocess, or spinner — still busy |
| Activity looks busy | **Unsubmitted** multi-line text stuck in the **input line** after `ntm send` (no Enter, or send raced the UI) |

**Rule:** for idle-gating, stall diagnosis, and proof that a marching order **actually ran**, prefer **`tmux capture-pane`** (see below) over Activity alone. Do not treat **«Sent to pane»** as proof the agent **executed** the prompt — only that text was injected.

### Idle gate (before a large `ntm send`)

Prefer a **recent pane capture** (last ~10–20 lines), for example:

```bash
tmux capture-pane -t <target-pane-spec> -p -S -25 | tail -n 15
```
Treat as **probably idle** only when capture matches **your** environment’s patterns, for example:

- prompt line with **empty** input after `❯` / `>`;
- stable “recap” / “Next: … poll inbox” style tail with no active spinner;
- not in the middle of a paste block.

Treat as **not idle** when you see **Compacting**, obvious **tool-running** banners, **Running …**, spinner lines, or a stuck “[Pasted text …” block. In that case:

1. **Do not** paste a new wall-of-text into the same pane this loop.
2. **Wait** one looper cycle and re-check, **or**
3. **Dispatch via Agent Mail** (preferred for async): `send_message` to the pane’s agent with the **full** role prompt in `body_md`, clear `subject` (e.g. `[marching-order] BD-123`), optional `ack_required` if you need explicit pick-up — the agent consumes it on the next `fetch_inbox` **without fighting the input box**.

### When to use which channel

| Channel | Use for |
| --- | --- |
| **Agent Mail `send_message`** | Next-bead / review / QA **full prompts**, redirects, anything that must not interrupt an active thinking turn |
| **`ntm send` + Enter** | **Short** wake-ups: `/clear`, one-line nudges, **initial** swarm bootstrap if mail not wired yet, emergency |

If you standardize on **mail for marching orders**, every worker/reviewer/QA must **poll inbox often** (about **60–90 seconds** during active swarm, or every looper cycle in instructions) so orders do not sit unread.

After **confirming idle**, you may still use `ntm send --file` for huge prompts if your `ntm` supports it — safer than paste into a live TUI.

## Self-Send Guard

Never send worker/reviewer/QA prompts to the orchestrator's own pane.

Before dispatch:

1. Determine which pane is the current orchestrator pane.
2. Remove that pane from all `ntm send --all`, role group, or bulk target lists.
3. Use explicit target lists when possible instead of broad `--all`.
4. If a command would include the orchestrator pane, rewrite the target set first.

The orchestrator may keep notes or reminders in its own context, but it must not `ntm send` a role prompt to itself.

## Role Separation Guard

Do not mix worker, reviewer, and QA roles.

Before every dispatch:

1. Check the pane map.
2. Confirm the target pane's assigned role.
3. Confirm the prompt type matches that role.
4. If the role must change, explicitly reassign the pane in the pane map first and tell the pane its new role.

Default separation:

| Role | Does | Does not do |
| --- | --- | --- |
| Worker | Implements beads, tests, closes, commits, pulls next bead | Reviews closed beads as final reviewer |
| Reviewer | Reviews closed beads, creates new beads for defects | Fixes defects by default |
| QA/E2E | Runs browser/E2E/smoke flows, creates defect beads | Implements fixes by default |
| Orchestrator | Coordinates, dispatches, resolves conflicts | Receives role prompts or does worker/reviewer/QA work by accident |

If a pane needs to switch roles, send an explicit reassignment prompt first, for example: "You are no longer reviewer R1; you are now worker W3." Then send the new role prompt.

## Pane Capacity, Auth Failures, And Role Failover

Swarm panes can become **unable to perform their role** even when tmux is "up": API **quota exhausted**, **rate limits** with no recovery in the observation window, **invalid or revoked keys**, repeated **401** / provider auth errors, or **silence**: no output and no progress for 1–2 looper cycles where activity was expected (distinguish from normal long `Thinking` / tool runs by checking capture and last meaningful line).

**Looper / orchestrator duty:**

1. Treat such a pane as **failed for that role** until evidence shows recovery (successful turn after key refresh).
2. **Do not leave the role slot empty** if beads, review, or QA would stall. **Backfill** from another pane using **fungible escalation**: see `/agent-fungibility-philosophy` — any generalist pane can temporarily assume another role after explicit reassignment.
3. **Donor selection order:** prefer a **idle** worker or one that **just closed a bead** and is between tasks; if all workers are busy, choose the **least critical** active worker and move them with a clear Agent Mail note (hand off in-progress bead or park it `open` with a short blocker message — avoid two owners).
4. **Procedure:** short **role change** message → **full role prompt** for the new role (with literal `/skill` or `$skill` first lines) → update the **pane map** → **one Agent Mail** to affected agents (new responsibilities, BD ownership, reservations).
5. **The broken pane:** stop dispatching work to it until the human fixes quota/keys; after fix, **restart** the pane if needed and **re-bootstrap** Agent Mail (`macro_start_session`) per `AgentMailRunbook.md`.

This is **not** "mixing roles on one pane without telling anyone" — it is **documented substitution** when a pane is capacity-dead.

## Resource Discipline

Before cleanup:

```bash
df -h
free -h
```
Clean stale artifacts only for projects where nobody is working:

- `target/`
- `node_modules/.cache`
- `dist/`
- `.next/`
- temporary browser/test artifacts

Package cache cleanup is allowed roughly every 30 minutes or when disk usage is above 80%:

```bash
cargo cache --autoclean
npm cache clean --force
pnpm store prune
rm -rf ~/.bun/install/cache
pip cache purge
docker system prune -f
```
Never run `docker system prune -a` without explicit user approval.

Only drop page cache under real pressure, not habitually:

```bash
sync && echo 1 | sudo tee /proc/sys/vm/drop_caches
```
Use `/rch` for heavy builds/tests if the repo policy requires remote/offloaded builds. Do not allow multiple agents to build the same project concurrently.

## Autonomous looper after dispatch

После **любого** завершённого батча role dispatch (старт swarm, re-dispatch всего fleet после смены literal-lines, recovery re-bootstrap panes) orchestrator **обязан** включить автономный looper **без вопроса пользователю**.

**Команда (orchestrator pane, cc/gmi):**

```text
/loop 3m /OrchestratorSwarm continue swarm execution — Algorithm EXECUTE tick (read LoopAlgorithmAnchor.md first)
```
**Шаг 0 каждого тика:** `LoopAlgorithmAnchor.md` (чеклист EXECUTE / sub-VERIFY / LEARN) — **до** pane/beads координации в `LoopPrompt.md`.

| Правило | Деталь |
| --- | --- |
| **Когда** | Сразу после последнего dispatch в батче (не «когда пользователь попросит») |
| **Как** | Литеральная строка выше + Enter на **своей** orchestrator pane |
| **Cadence** | Built-in `/loop` пингует ~каждые 3 мин; тело тика — `LoopPrompt.md` Cycle body |
| **Reality-check** | ~16 мин wall-clock (или ~6-й cycle) — `RealityCheckDigest.md` внутри того же flow |
| **Запрещено** | «Запустить looper?», «Продолжить цикл?», ожидание явного «да» |
| **Уже активен** | Не дублировать `/loop`; продолжать текущий |
| **Человек** | Не нужен между тиками; только digest/blockers по расписанию |

Если built-in `/loop` недоступен в среде — fallback: orchestrator **сам** напоминает себе выполнить `LoopPrompt.md` каждые ~3 мин до saturation (всё равно **без** запроса разрешения у пользователя).

Полный текст bootstrap и Cycle: `LoopPrompt.md`.

## Looper

**Reality-check digest (~every 16 minutes):** Emit at least **16 minutes** after the previous digest (wall-clock), or approximately every **sixth** full loop pass if spacing is ~3 minutes (~18 minutes). Output a human-facing progress summary per **`RealityCheckDigest.md`**. It must compare **stage/phase progress to the project’s original plan** (plan doc, README roadmap, epics), not only bead close counts: bars, pane×bead table, velocity vs plan budget, blockers, quality/review signal, main risk. Skip this wall of text on intervening loop ticks.

Every ~3 minutes (via `/loop 3m …` or manual Cycle), inspect every pane **by explicit checklist** (do not assume «I would have noticed»):

- Is the process alive?
- Does it have a current bead or a clear «between tasks» state only **after** Mail+bv?
- Has stdout/stderr changed?
- Is it waiting for input?
- Is there Agent Mail file overlap?
- Did you run **`am robot reservations --conflicts`** (or MCP equivalent) this loop for the swarm’s `project_key`?
- Any pane hit **quota / rate limit / invalid key / auth** errors, or **no progress** 1–2 loops where you expected work — needs **role failover** (see **Pane Capacity, Auth Failures, And Role Failover**), not just waiting?
- Is a heavy build/test conflicting with another pane?

If an agent is idle:

```bash
bv --robot-triage --format toon
bv --robot-next
```
Prefer work that **closes the bead** and **unblocks the graph**; do not reward panes that only grow unrelated test surface. See `Gotchas.md` → **Goal-First Delivery**.

Then send the next ready/open bead with a role prompt from `RolePrompts.md` — **to every worker that needs one this cycle**, not a minimal subset.

**Before** that send: apply the **idle gate** in **NTM Send, Busy Panes, And Input Stuck-Text** — or deliver the same prompt via **Agent Mail** if the pane is not idle. Do not lose a two-page prompt to a thinking-loop input race.

For bugs, review, E2E, auth, migrations, MCP, Mastra, or UI work, choose skills from `SkillRouting.md`. Simple tasks may skip `ms`; complex tasks should run:

```bash
ms search "query" --robot
```
If `ms search` returns nothing useful or the exact skill is missing, choose the closest semantically appropriate fallback from `SkillRouting.md` and keep moving. Do not invent a skill name and do not block the swarm solely because one skill is unavailable.

## Worker Continuity

Workers do not stop after closing a bead. A worker's normal lifecycle is:

1. finish current bead;
2. run relevant checks;
3. close the bead;
4. commit through the commit skill;
5. **check Agent Mail** for marching orders, then immediately look for the next ready/open bead;
6. select a fresh skill bundle for that new bead;
7. claim it and continue working.

**No terminal idle:** A worker must not end a turn at an empty prompt unless they have just polled Mail + `bv` and there is genuinely no actionable work — then one short status (Mail or explicit line) and remain ready to grab the next assignment. «Done» without pull-next is a protocol violation.

For every new bead, the worker or orchestrator must re-evaluate skills from scratch. Do not reuse the previous bead's skill bundle blindly.

**Triage before churn:** use `bv --robot-triage` / `bv --robot-next` (and `/beads-bv` / `$beads-bv` when needed) so work tracks **bottlenecks** and bead **outcomes**, not maximal test LOC.

Required next-bead flow:

```bash
bv --robot-next
ms search "<new bead topic>" --robot
br update <next-id> --status in_progress
```
Use `SkillRouting.md` first, then `ms search` when the next bead's domain is not already covered by the worker's current context. If the new bead is a bug, review, E2E, auth, migration, MCP, Mastra, UI, parser, or integration task, skill selection is mandatory.

## Role self-loops (worker, reviewer, QA)

The orchestrator’s **`LoopPrompt.md`** cadence (~3 min) coordinates the **fleet**. Each non-orchestrator pane also runs a **lighter self-loop** from this skill so agents re-read their role rules, Mail, and anti-idle checks without waiting for the orchestrator:

| Role | File | Typical cadence | Skill prefix |
| --- | --- | --- | --- |
| Worker | `WorkerLoopPrompt.md` | ~**6 min** | `cc`/`gmi`: `/` · `cod`: `$` |
| Reviewer | `ReviewerLoopPrompt.md` | ~**6 min** | same |
| QA | `QALoopPrompt.md` | ~**6 min** | same |

**Orchestrator:** every marching order MUST include an explicit self-loop line (see `RolePrompts.md` → **Every role prompt must include** and **Looper Dispatch Rule**).

**Agents:** do not interrupt mid-tool; run the self-loop at the next natural pause. Self-loop complements marching orders; it does not replace inbox polling after every bead close.

If a pane is stuck for more than one loop:

1. Send `/clear` or the CLI equivalent.
2. If still unresponsive next loop, restart the pane.
3. If the agent held a bead, inspect for useful partial changes, then return the bead to `open` if the agent is dead.

## Stalled Beads

Stalled signals:

- pane died or does not respond;
- no activity for more than one looper cycle;
- bead status does not change;
- Agent Mail reservation has no live owner.

Recovery:

1. Record which agent held the bead.
2. Check for useful uncommitted changes.
3. If dead, return the bead to open:

```bash
br update <id> --status open
```
4. If partial work exists, create a cleanup/recovery bead or pass context to the replacement agent.

## Stale Bead Detection And Reassignment (~12 min cadence)

A bead is **stale** when it has been `in_progress` for an extended period without measurable activity. This differs from a "stalled bead" (dead pane) — a stale bead may have a live pane that is stuck, lost, or silently switched to another task without releasing the bead.

### Detection procedure (every ~12 min)

1. Run:

```bash
br list --status in_progress
```
2. For each `in_progress` bead, check:
   - **Holder pane activity**: `tmux capture-pane` on the pane that claimed the bead — is it actively working on this bead, or idle/parked on something else?
   - **Last meaningful output**: no tool calls, no bash progress, no file edits for >~20 min on this bead.
   - **Agent Mail reservations**: does the holder still have active file reservations for this bead's files? If the pane is dead or abandoned, reservations may be stale.

3. **Stale indicators** (any one is enough to trigger reassignment):
   - Bead in `in_progress` >~20 min with no tool output from holder pane.
   - Holder pane is at **empty prompt** without this bead assigned (abandoned without release).
   - Holder pane is working on **different bead** without having closed/transferred this one.
   - Pane holding the bead is dead (quota death, restart, silent) — bead must be recovered.

### Reassignment procedure

1. **First attempt: wake up** — send `/clear` + message via Agent Mail to holder: "Bead <BD-ID> appears stale. Confirm you are working on it, or release it."

2. **If no response in one looper cycle** or holder clearly abandoned:
   - Return bead to `open`: `br update <BD-ID> --status open`.
   - Check `git status` / `git diff` for partial work from the abandoned holder; if found, create a recovery bead or note in the reassigned bead.
   - Assign to another suitable worker with full dispatch (literal `/skill` or `$skill` first lines + `/goal` if complex).
   - Agent Mail notification to both old and new holder: "Bead <BD-ID> reassigned from [old] to [new], old holder freed."

3. **Threshold for force-reassign**: ~30 min in `in_progress` with no verified activity. If in doubt, reassign rather than leave blocked.

### Anti-patterns to avoid

- Do NOT close a stale bead as `done` without verification — close only with explicit completion or transfer.
- Do NOT reassign a bead that is actively being worked on (capture confirms real progress). Use judgment: long Thinking is OK, spinning on the same command >2 cycles is not.
- Do NOT leave a stale bead blocking the graph while another worker sits idle.

## Completion Loop

Keep the swarm alive while any of these exist:

- open beads;
- ready beads;
- stalled beads;
- review findings that need beads;
- failing critical checks;
- incomplete recovery after agent failure.

**AFK mode (operator absent):** Do not wait for user replies between looper ticks. Track `afk_stall_loops`; after **6** ticks without progress or after **one failed recovery** on a hard blocker, **stop** `/loop` and write **`docs/swarm-afk-exit-handoff.md`** per **`AFKExitHandoff.md`**. Do not spin the loop indefinitely. PRD stays `phase: execute` until human resumes or true saturation triggers LEARN.

When no open/ready beads remain:

1. Run review via `/vibing-with-ntm`, `/ce-review`, or `/ce-code-review`.
2. Run saturation checks as applicable:
   - `/mock-code-finder`
   - `/reality-check-for-project`
   - `/ubs`
   - `/multi-pass-bug-hunting`
   - `/e2e-testing-for-webapps`
3. Turn findings into new beads using `br` / `/beads-workflow`.
4. Resume the swarm loop.

Final stop is allowed when: the user explicitly stops the swarm; **AFK exit** handoff is written (`AFKExitHandoff.md`); or all saturation criteria are met and `br sync --flush-only` has run.
