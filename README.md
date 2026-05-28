# OrchestratorSwarm

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill](https://img.shields.io/badge/type-agent--skill-blue.svg)](#installation)

**Run a multi-agent coding swarm until your Beads backlog is done — workers, reviewers, QA, looper, and reality-checks included.**

</div>

OrchestratorSwarm is an **agent skill** (prompt + SOP bundle) for operating fleets of CLI coding agents in tmux. It sits on top of [NTM](https://github.com/Dicklesworthstone/ntm) and the [Agentic Coding Flywheel](https://github.com/Dicklesworthstone/agentic_coding_flywheel_setup) stack.

<div align="center">

### Quick Install

```bash
git clone https://github.com/Diffuzmetall/orchestrator-swarm.git
cd orchestrator-swarm && ./install.sh
```

**Or one-liner (after you publish the repo):**

```bash
curl -fsSL https://raw.githubusercontent.com/Diffuzmetall/orchestrator-swarm/main/install.sh | bash
```
</div>

---

## TL;DR

**The Problem:** Running 5–10 coding agents in parallel sounds great until panes stall, agents pick the wrong skills, beads close without evidence, Agent Mail dies, and nobody knows if you're still on plan.

**The Solution:** OrchestratorSwarm turns you into a **general orchestrator** with explicit procedures: role-separated dispatch (worker / reviewer / QA), a **3-minute autonomous looper**, **16-minute reality-check digests**, PRD-synced EXECUTE phase, pane failover, and ground-truth verification via `tmux capture-pane` — not shallow status polling.

### Why Use OrchestratorSwarm?

| Feature | What It Does |
|---------|--------------|
| **Three-layer stack** | `/ntm` → `/vibing-with-ntm` → `/OrchestratorSwarm` — use only the depth you need |
| **Literal skill dispatch** | Forces `/agent-mail`, `/ce-work`, … as first lines so skill calls actually fire |
| **Role separation** | Workers ship beads; reviewers catch "closed without evidence"; QA runs gates |
| **Autonomous looper** | `/loop 3m` keeps the swarm moving without asking permission every tick |
| **PRD-aligned EXECUTE** | Maps bead closes → ISC criteria; reality-check writes verification evidence |
| **Recovery runbooks** | Agent Mail down, orphan panes, rate limits, AFK exit handoff |

---

## Quick Example

```bash
# 0. Prerequisites (Flywheel VPS or manual install)
ntm deps -v && br ready && bv --robot-triage

# 1. Plan first — PRD exists before swarm (see docs/PRD-FORMAT.md)
#    docs/work/my-feature/PRD.md  with ## Criteria checkboxes

# 2. Spawn mixed agent panes
ntm spawn myproject --cc=3 --cod=2 --gmi=1

# 3. In orchestrator pane (Claude Code / Cursor)
/OrchestratorSwarm
# User: "5 workers, 2 reviewers, 1 QA — run the backlog"

# 4. Skill runs: Agent Mail preflight → pane map → role dispatch
#    → immediately starts: /loop 3m … continue swarm execution

# 5. Monitor (human or orchestrator looper)
ntm --robot-snapshot
tmux capture-pane -p -t myproject:0.1 -S -20   # ground truth

# 6. Stop when saturated or user says stop
#    → VERIFY → LEARN → docs/swarm-learnings/reflections.jsonl
```
**Codex orchestrator:** invoke `$OrchestratorSwarm` instead of `/OrchestratorSwarm`.

---

## Design Philosophy

1. **NTM is the machine; OrchestratorSwarm is the conductor.** Never bypass NTM for pane ops — spawn, send, snapshot all go through it.

2. **Show, don't trust status lights.** NTM Activity can lie (`WAITING` while thinking). Read pane buffers and verify artifacts on disk before declaring victory.

3. **Literal lines invoke skills; prose does not.** A marching order that says "Skills: ce-work, agent-mail" often results in zero skill calls. Dispatch must list `/agent-mail` then `/ce-work` as separate lines.

4. **Goal-first, not test theater.** Close beads correctly; add tests where risk demands — not blanket suites for theater.

5. **One PRD, one EXECUTE arc.** The swarm executes an existing plan document; it doesn't invent a parallel meta-plan.

---

## How OrchestratorSwarm Compares

| Capability | OrchestratorSwarm | `/vibing-with-ntm` | `/ntm` alone | Manual tmux |
|------------|-------------------|---------------------|--------------|-------------|
| Spawn mixed cc/cod/gmi | ✅ | ✅ | ✅ | ⚠️ Manual |
| Agent Mail + Beads | ✅ | ✅ | ⚠️ Partial | ❌ |
| Worker/reviewer/QA roles | ✅ | ⚠️ Ad hoc | ❌ | ❌ |
| 3m autonomous looper | ✅ | ❌ | ❌ | ❌ |
| Reality-check vs PRD | ✅ | ❌ | ❌ | ❌ |
| Pane recap + artifact verify | ✅ | ⚠️ | ❌ | ❌ |
| AFK exit handoff | ✅ | ❌ | ❌ | ❌ |
| Setup complexity | High | Medium | Low | Low |

**Use OrchestratorSwarm when:** you have a Beads backlog, multiple agent types, and want AFK-capable orchestration with review separation.

**Use `/vibing-with-ntm` when:** coordination + marching orders, but no full looper/reality-check choreography.

**Use `/ntm` alone when:** you just need to spawn a session or send one message.

---

## Installation

### From git (recommended)

```bash
git clone https://github.com/Diffuzmetall/orchestrator-swarm.git
cd orchestrator-swarm
chmod +x install.sh
./install.sh                    # → ~/.claude/skills/OrchestratorSwarm/
./install.sh --target ~/.cursor/skills-cursor   # Cursor layout
```
### Manual

Copy this repo's skill files (everything except `README.md`, `LICENSE`, `install.sh`, `AGENTS.md`) into:

```text
~/.claude/skills/OrchestratorSwarm/
```
### Flywheel ecosystem (full stack)

Install [agentic_coding_flywheel_setup](https://github.com/Dicklesworthstone/agentic_coding_flywheel_setup) on a VPS, then add this skill. See [`docs/ECOSYSTEM.md`](docs/ECOSYSTEM.md) for the tool chain:

| Tool | Purpose |
|------|---------|
| [ntm](https://github.com/Dicklesworthstone/ntm) | tmux multi-agent sessions |
| [beads_rust](https://github.com/Dicklesworthstone/beads_rust) | `br` / `bv` issue graph |
| [mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail) | file locks + inbox |
| vibing-with-ntm skill | coordination layer |
| **OrchestratorSwarm** | full orchestrator (this repo) |

---

## Quick Start

1. **Install prerequisites** — at minimum `ntm`; strongly recommended `br`, `bv`, Agent Mail MCP.
2. **Install this skill** — `./install.sh`
3. **Install companion skills** — `ntm`, `vibing-with-ntm`, `agent-mail`, `beads-bv`, `/loop`
4. **Create a PRD** — template in [`docs/PRD-FORMAT.md`](docs/PRD-FORMAT.md); decompose work into beads (`br`)
5. **Spawn panes** — `ntm spawn PROJECT --cc=N --cod=M --gmi=K`
6. **Invoke** — `/OrchestratorSwarm` and specify role counts: *"4 workers, 2 reviewers, 1 QA"*
7. **Walk away (optional)** — looper runs every 3 minutes; check reality-check digests ~every 16 min

---

## Skill Workflows

| Trigger | Workflow file | Purpose |
|---------|---------------|---------|
| Start swarm | `OperatingProcedure.md` | Preflight → dispatch → start looper |
| Continue loop | `LoopPrompt.md` | ~3 min orchestrator tick |
| Worker/reviewer/QA | `WorkerLoopPrompt.md`, etc. | Role self-loops ~6–12 min |
| Progress vs plan | `RealityCheckDigest.md` | ~16 min digest |
| Stalled / Mail down | `AgentMailRunbook.md` | Recovery |
| AFK / sleep | `AFKExitHandoff.md` | Stop loop + handoff doc |
| PRD sync | `AlgorithmIntegration.md` | EXECUTE / VERIFY / LEARN |
| Skill picking | `SkillRouting.md` | Route beads to workflows |

Full trigger list: [`SKILL.md`](SKILL.md)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Human operator                                │
│              (role counts, stop/resume, AFK)                         │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│              Orchestrator pane (/OrchestratorSwarm)                  │
│   LoopPrompt (~3m) │ RealityCheck (~16m) │ Dispatch │ Recovery    │
│   PRD sync (ISC)   │ tmux capture-pane     │ Agent Mail ops         │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ ntm send / spawn / robot-snapshot
                                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Worker cc/cod│  │ Worker …     │  │ Reviewer …   │  │ QA …         │
│ br claim     │  │ br claim     │  │ review loops │  │ test gates   │
│ self-loop    │  │ self-loop    │  │              │  │              │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │                 │
       └─────────────────┴────────┬────────┴─────────────────┘
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│ Coordination layer                                                   │
│  Agent Mail (reservations, inbox)  │  Beads br/bv (backlog graph)    │
└───────────────────────────────┬─────────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│ NTM + tmux                                                           │
│  sessions · panes · capture-pane · pipeline · quota/rotate           │
└─────────────────────────────────────────────────────────────────────┘
```
---

## Configuration

### Operator customizations

```bash
mkdir -p ~/.config/orchestrator-swarm
# Edit PREFERENCES.md — see docs/CUSTOMIZATION.md
```
### Project-level (always wins)

```text
<repo>/AGENTS.md
<repo>/CLAUDE.md
<repo>/docs/work/*/PRD.md
<repo>/.beads/
```
### Optional PAI / Flywheel memory

If you run the full personal stack, enable patterns from:

`optional-extensions/MemoryIntegration-PAI.md`

---

## Troubleshooting

### "Skill calls stay at 0"

Dispatch used prose `Skills: …` instead of literal lines. Re-dispatch **every** pane with:

```text
/agent-mail
/ce-work
```
(Codex: `$agent-mail`, `$ce-work`)

### "NTM says WAITING but agent is working"

Don't trust Activity alone:

```bash
tmux capture-pane -p -t SESSION:PANE -S -20
```
See `PaneRecapReading.md`.

### "Agent Mail MCP unavailable"

Follow `AgentMailRunbook.md` — restart MCP, `doctor reconstruct`, re-register orphan panes. Never paste bearer tokens into beads or PRD.

### "Beads closed too fast / no evidence"

Reviewer pattern: triangulate pane recap + `br show --json` close reason + disk (`test -f`, `git log`). Reopen bead if needed.

### "Looper asks permission every tick"

After initial dispatch, orchestrator must run autonomously:

```text
/loop 3m /OrchestratorSwarm continue swarm execution — read LoopAlgorithmAnchor.md first
```
Never ask "start looper?" between ticks.

---

## Limitations

### What OrchestratorSwarm Doesn't Do

- **Planning from scratch** — use planning skills / PRD creation *before* swarm; not `_PLAN_TO_SWARM` replacement
- **Replace NTM** — all tmux operations still go through NTM
- **Worktrees by default** — policy is main-only; override only if target repo AGENTS.md allows
- **Guarantee agent quality** — SOP reduces failure modes; bad models or prompts still fail

### Known Constraints

| Topic | State | Notes |
|-------|-------|-------|
| Non-Flywheel minimal setup | ⚠️ Partial | Needs adapted prompts without Mail/Beads |
| Windows native tmux | ❌ | Use WSL2 + Linux tmux |
| Non-tmux agents | ❌ | Designed for cc/cod/gmi in tmux panes |

---

## FAQ

### When should I use OrchestratorSwarm vs vibing-with-ntm?

**vibing-with-ntm** — marching orders and Beads coordination for a small swarm.

**OrchestratorSwarm** — 5+ panes, explicit reviewer/QA separation, autonomous looper, PRD-tracked EXECUTE, AFK handoff.

### Do I need the full Flywheel VPS?

No. Minimum: tmux + ntm + a task list. Beads + Agent Mail strongly recommended. CASS/CM/PAI memory optional.

### cc vs cod skill syntax?

| Agent | Invoke |
|-------|--------|
| Claude Code (`cc`) | `/skill-name` |
| Codex (`cod`) | `$skill-name` |
| Gemini (`gmi`) | `/skill-name` |

### Where does the PRD live?

Prefer `docs/work/<slug>/PRD.md` or `MEMORY/WORK/<slug>/PRD.md`. Format: [`docs/PRD-FORMAT.md`](docs/PRD-FORMAT.md).

### Can I run this in Cursor?

Yes. Install to `~/.cursor/skills-cursor/OrchestratorSwarm/` or symlink from `~/.claude/skills/`.

### How does this relate to the Flywheel?

[Agentic Coding Flywheel Setup](https://github.com/Dicklesworthstone/agentic_coding_flywheel_setup) installs the **tools** (ntm, br, bv, mail). OrchestratorSwarm is the **operator playbook** for running them at scale. See [`docs/ECOSYSTEM.md`](docs/ECOSYSTEM.md).

---

## Repository Layout

```text
SKILL.md                 # Entry point, triggers, constraints
OperatingProcedure.md    # Start / recover swarm
LoopPrompt.md            # Orchestrator looper (~3 min)
RolePrompts.md           # Worker / reviewer / QA templates
AlgorithmIntegration.md  # PRD EXECUTE lifecycle
MemoryIntegration.md     # Core + optional memory
docs/
  ECOSYSTEM.md           # NTM + Flywheel map
  PRD-FORMAT.md          # PRD template
  CUSTOMIZATION.md       # ~/.config overrides
optional-extensions/
  MemoryIntegration-PAI.md  # Full PAI/CASS/CM (Flywheel operators)
install.sh
```

---

## About Contributions

> *About Contributions:* Please don't take this the wrong way, but I do not accept outside contributions for any of my projects. I simply don't have the mental bandwidth to review anything, and it's my name on the thing, so I'm responsible for any problems it causes; thus, the risk-reward is highly asymmetric from my perspective. I'd also have to worry about other "stakeholders," which seems unwise for tools I mostly make for myself for free. Feel free to submit issues, and even PRs if you want to illustrate a proposed fix, but know I won't merge them directly. Instead, I'll have Claude or Codex review submissions via `gh` and independently decide whether and how to address them. Bug reports in particular are welcome. Sorry if this offends, but I want to avoid wasted time and hurt feelings. I understand this isn't in sync with the prevailing open-source ethos that seeks community contributions, but it's the only way I can move at this velocity and keep my sanity.

---

## License

MIT — see [LICENSE](LICENSE).

---

## Acknowledgments

Built for the [Agentic Coding Flywheel](https://github.com/Dicklesworthstone/agentic_coding_flywheel_setup) ecosystem:

- [NTM](https://github.com/Dicklesworthstone/ntm) by Dicklesworthstone
- [beads_rust](https://github.com/Dicklesworthstone/beads_rust)
- [mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail)

Extracted and sanitized from a production operator workflow for sharing.
