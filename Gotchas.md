# Gotchas

## Pane Map Is The Orchestrator's Job

Do not ask the user to manually list every pane as `pane 0 = ...`, `pane 1 = ...`.

The user provides the desired role mix/counts, for example "5 workers, 2 reviewers, 1 QA". The orchestrator inspects NTM/tmux panes, detects CLI types where possible, builds the pane map, and assigns roles. Ask the user only if there are not enough panes or CLI types are ambiguous.

## Do Not Send Prompts To Yourself

The orchestrator must identify its own pane and exclude it from dispatch target lists.

Never send worker, reviewer, QA, or looper role prompts to the orchestrator pane. Be especially careful with broad `ntm send --all` or role groups that might include self. Prefer explicit target lists after building the pane map.

## Do Not Mix Roles

Worker, reviewer, and QA panes are not interchangeable by accident.

Before every dispatch, check the pane map and prompt type:

- worker prompt -> worker pane only;
- reviewer prompt -> reviewer pane only;
- QA prompt -> QA pane only.

If a pane must change roles, explicitly reassign it first and tell the pane its new role. Reviewers create beads instead of fixing by default; QA creates defect beads instead of implementing fixes by default.

## Agent Mail Is For Every Pane

Agent Mail is not only an orchestrator tool. Every worker, reviewer, and QA pane must check inbox/reservations regularly and use mail for blockers, file overlap, handoffs, and `ack_required` replies.

Coordination must be high-signal. Do not spam status chatter, "FYI" noise, or conversational back-and-forth. Send mail when it changes another agent's actions: file ownership, blocker, handoff, conflict, review finding, ack-required decision, or completion that unblocks others.

If a pane ignores Agent Mail, treat it as unhealthy: remind it once, then stop assigning new work until it starts checking mail and reservations.

## Workers Must Not Park At Empty Prompt

**Workers** (and reviewers/QA when between assignments) must not treat «task finished» as a stopping state. After every close/commit: **Mail poll first**, then `bv` for next work, then claim or explicit blocker in Mail. **Orchestrators** must scan **all** panes each loop — not only those who «скрипят» loudest; idle worker with no `in_progress` and no verified «no ready beads after Mail+bv» is a **dispatch failure** — use **Agent Mail** for marching orders when `ntm paste` is unsafe, but **never** skip half the fleet out of caution. **Stuck input** (truncated paste, garbage line) on an otherwise idle pane: `/clear`, then resend via Mail.

See `RolePrompts.md` → worker **Запрет терминального простоя** and **Looper Dispatch Rule**.

## Autonomous looper must start without asking

After fleet dispatch, the orchestrator **must** run `/loop 3m /OrchestratorSwarm continue swarm execution — Algorithm EXECUTE tick (read LoopAlgorithmAnchor.md first)` on its own pane immediately. **Never** ask the user «start the looper?» Each tick: **`LoopAlgorithmAnchor.md` step 0** before pane coordination — do not drift into beads-only mode without PRD/ISC updates.

See `LoopPrompt.md`, `LoopAlgorithmAnchor.md`, `OperatingProcedure.md` → **Autonomous looper after dispatch**.

## AFK: no infinite looper

When the user is AFK (LaunchAFK / no replies):

- **Do not** ask the user questions between ticks.
- Maintain **`afk_stall_loops`** (+1 per ~3 min tick with zero progress).
- At **`>= 6`** stall ticks (~18 min) **or** unrecoverable blocker after one recovery → **`/loop stop`**, Mail «AFK PAUSE», write **`docs/swarm-afk-exit-handoff.md`** (`AFKExitHandoff.md`).
- AFK exit is **not** LEARN — leave `phase: execute` unless saturation; human reads exit handoff and resumes.

## Role self-loops

Parallel to the orchestrator **LoopPrompt** (~3 min), each role runs its **self-loop** from this skill: `WorkerLoopPrompt.md` (~**6** min), `ReviewerLoopPrompt.md` and `QALoopPrompt.md` (~**6** min). **cc/gmi** use `/` for skills; **cod** uses `$`. The orchestrator must include the self-loop instruction in every dispatch (`OperatingProcedure.md` → **Role self-loops**).

## Missing Skill Is Not A Stop Condition

If the exact skill is missing or `ms search` returns nothing useful, pick the closest semantically appropriate skill and keep moving.

Do not invent skill names. If the same missing skill is needed repeatedly, create a follow-up note or bead to install/create it later.

## Worktree Drift

Many swarm and work-execution skills mention worktrees as an isolation option. In this environment, that is wrong.

Always override to: current checkout on `main`, no worktrees.

## Codex `/goal` For Non-Trivial Work

On **`cod`** panes, **complex** beads (multi-file, unclear acceptance, integration risk) should include the slash command **`/goal`** with **verifiable criteria** (ISC-style measurable criteria), not only a one-line bead summary. Prose "Цель: …" in the body without a literal **`/goal`** invocation does not invoke Codex goal framing. See `GoalDispatch.md` and `RolePrompts.md` → worker `cod` block. Order: **`$agent-mail`** → **`/goal`** → other **`$skill`** lines (`/goal` is slash; skill registry lines remain `$…`).

## Skill Syntax Drift

The same skill name needs different invocation syntax by pane:

- Claude Code: `/ce-review`
- Codex: `$ce-review` for **skill registry** invocations; built-in **`/goal`** uses **slash** (see `GoalDispatch.md`)
- Gemini (`gmi`): `/ce-review`

Before every `ntm send`, adapt the skill bundle to the pane type.

## "Skills:" Prose Lists Do Not Invoke Skills

If the prompt only says `Skills: /ce-work, /find-docs` inline, models often **skip** formal skill invocation and jump to bash/edit/read. Session analytics then show **Skill calls = 0** even when work happened.

Always require an **ordered block of literal lines** starting with `/skill` or `$skill` (see `RolePrompts.md` → **ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ** / **Первое действие**). The orchestrator and looper must include this block in every `ntm send` dispatch body.

**Partial rollout illusion:** Updating prompts for **one** worker while R1/R2/W3 still have old “Скиллы: …” text produces **real** metrics like “1 pane = 3 skill calls, 9 sessions = 0”. That is a dispatch gap, not a broken skill system.

## NTM Activity Is Not Ground Truth — Use tmux capture-pane

**NTM Activity**, **robot-snapshot**, and similar summaries are a **fast heuristic**, not a substitute for reading the pane.

- A pane can show **`WAITING`** / «ждёт ввода» while the agent is actually **streaming `Thinking`**, running **tools**, or updating the TUI — Activity lags or misclassifies.
- Conversely, Activity can look «busy» while the real problem is **stuck paste**: prompt text **sits in the input line** and **never submitted** after `ntm send` — orchestration error, not agent laziness.

**Orchestrator / looper duty:** when deciding idle vs busy, stalled vs healthy, or whether a dispatch **actually started**, always cross-check with **`tmux capture-pane`** (last ~10–20 lines; same pattern as idle-gate in `OperatingProcedure.md`). Treat **«Sent to pane»** as delivery to the **input buffer** only; execution is proven by capture (new turn output, tool banners, or a clean post-submit prompt), not by the send ACK alone.

## NTM Paste Into A Busy Pane Eats Prompts

`ntm send` targets the **input buffer**. If the agent is **thinking**, **tool-running**, or **compacting**, your multi-line order often **does not submit**, **merges badly** with paste state, or **disappears** on Esc. That is not flaky agents — it is **wrong transport**.

Use **Agent Mail `send_message`** for full marching orders when the pane is not idle, and reserve `ntm send` for **short** control (`/clear`, one-liner). See `OperatingProcedure.md` → **NTM Send, Busy Panes, And Input Stuck-Text**.

**`ntm --robot-send` without session name:** `ntm --robot-send --panes=2 --msg-file=…` fails (`invalid session name: "--panes=2"`). Always `ntm --robot-send=PROJECT` or `ntm --robot-send PROJECT` first. SOP: `~/.claude/skills/_PLAN_TO_SWARM/RobotSendDispatch.md`.

**`$model` / multiline in zsh:** Never put `$model gpt-5.5-high` in msg-file or shell args — zsh runs lines as commands if the pane is still shell. Use `--msg-file` only after Codex UI is up.

## "Agents Will Figure It Out" Is A Trap

Do not rely on workers/reviewers/QA agents to infer the right skill stack. The orchestrator sends role prompts with explicit **slash lines to execute first**. Agents may add up to 3 extra skills through `ms search`, but the baseline bundle comes from the orchestrator as invocations, not hints.

## Workers Must Keep Pulling Work

Workers do not stop after a successful bead. After checks, close, and commit, they immediately pick the next ready/open bead and refresh the skill bundle for that bead.

Do not let a worker continue with stale skills from the previous task. New bead means new skill selection: `SkillRouting.md` first, then `ms search "<new bead topic>" --robot` when needed.

## Agent Mail Before Swarm

Agent Mail/MCP preflight is a hard gate. If mail is broken, file reservations and overlap checks become unreliable. Repair or get explicit user permission to fail open.

## Agent Mail Restart Window = Orphan Panes

A live Agent Mail PID or a successful MCP handshake once is not forever. **Server restarts, token drift, and transient socket errors** leave panes “working” but **unregistered**: no reservations, no inbox, misleading safety.

After any known or suspected Agent Mail outage: reconcile pane count vs registered agents, then **re-bootstrap every affected pane** (`macro_start_session`). Do not trust file reservations until then.

Operational ladder and symptom table: `AgentMailRunbook.md`. Persist lessons via `/cass`, `/cm`, `/ce-compound`, or PRD `## Decisions` **without secrets**.

**Index corruption:** errors mentioning **malformed** or **`idx_agents_*`** after restarts/disk issues often need **`doctor reconstruct`** (with the **daemon stopped** first), not only `doctor repair`. See `AgentMailRunbook.md` → **Index reconstruct**.

## File Reservation Overlap Is A Looper Duty

The ~3 minute loop is not only beads and pane liveness. Each cycle should **actively detect overlapping Agent Mail reservations** on the same repo (for example `am robot reservations --conflicts`). Two agents editing intersecting globs without coordination is a **pre-merge conflict**. Resolve through Agent Mail, not after `git merge` explosions.

## Quota, Keys, And Role Failover

A pane can be "alive" in tmux but **dead for work**: quota exhausted, rate limits, invalid API key, or stuck auth. The looper should **promote a donor pane** (usually idle or post-close worker) to cover a failed reviewer/QA/worker slot with **explicit reassignment + Mail**, per `OperatingProcedure.md` → **Pane capacity, auth failures, and role failover**. Do not let review or beads stall because one CLI ran out of credits.

## Goal-First Delivery (Avoid Test Theater)

Workers and orchestrators should optimize for **closing the right bead** and **unblocking the graph**, not for maximizing test file count.

- Use **`bv --robot-triage`**, **`bv --robot-next`**, and **`br ready`** (as documented in the repo) to see **bottlenecks** before churning auxiliary code.
- Write **enough** tests: regressions, contracts, critical paths touched by the change. **Do not** add broad suites or duplicate coverage “for hygiene” when it does not reduce real risk for this bead.
- Load **`/beads-bv`** (**`$beads-bv`** on Codex) when triage workflow is non-obvious.

## Closed Beads Stay Closed

Reviewers do not reopen completed beads just because they found a defect. They create new beads for review findings. Reopen only when the original work was not actually completed or the owner died mid-task.

## Build Contention

One project-level swarm must not run parallel builds of the same project. The looper should notice active build/test commands and route other panes to non-conflicting work.

## Resource Cleanup Safety

Always run `df -h` and `free -h` before cleanup. Do not run `docker system prune -a` without explicit permission. Drop page cache only under real pressure.

## Stalled Pane Recovery

Do not immediately kill a stuck pane. First send `/clear` or equivalent, then wait one loop. If still dead, restart and recover its bead.

## Clawpatch In A Swarm

`clawpatch` is a useful deep-review tool (see `SkillRouting.md` → Reviewer / QA Routing, full contract in `INSTRUCTIONS.md` → Clawpatch), but it has multi-agent footguns:

1. **`.clawpatch/` MUST be gitignored** in any repo where the swarm runs. Findings, patches, runs are local state — committing them turns one agent's transient view into shared truth and creates noise across panes. First swarm action in a fresh repo: `echo '.clawpatch/' >> .gitignore` if missing.
2. **`fix` requires a clean worktree** by default (`git.requireCleanWorktreeForFix: true`). In a swarm this is a **feature, not a bug** — it prevents one fixer from overwriting another worker's in-flight edits. Do not flip it off in `.clawpatch/config.json` to "save a step".
3. **One agent owns a finding's `fix` at a time.** Coordinate via Agent Mail **file reservation** on the finding's owned files (`clawpatch show --finding <id>` lists them) **before** running `clawpatch fix`. Reviewer/QA never run `fix` — that is worker work.
4. **Locks in `.clawpatch/locks/`** are authoritative. Run `clawpatch clean-locks` only after confirming via Agent Mail + `bv` that no other pane is mid-review. Stale locks from an interrupted run will block re-review.
5. **Findings → beads, не повторный review.** When a `clawpatch review` produces material findings, feed them to `br` (with severity/category from the report) instead of re-running `review` from another pane.
6. **Provider rate-limits / quota:** `clawpatch review --jobs 4` against `codex` consumes the same Codex CLI accounts that workers/QA use. Coordinate via `caam` if the swarm is large; consider `--provider acpx --model claude:<...>` to spread load.

## Functional Validation

After creating or updating this skill:

```bash
ms index
ms search "orchestrator swarm ntm beads looper" --robot
```
Expected: `OrchestratorSwarm` appears in results.
