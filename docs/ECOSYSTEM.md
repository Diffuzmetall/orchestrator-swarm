# Flywheel Ecosystem — How OrchestratorSwarm Fits

OrchestratorSwarm is the **top layer** of a three-level stack for multi-agent coding on tmux. It assumes (but can partially work without) tools from the [Agentic Coding Flywheel Setup (ACFS)](https://github.com/Dicklesworthstone/agentic_coding_flywheel_setup).

---

## Skill hierarchy

```
/ntm                    ← tmux sessions, panes, send, robot monitoring
   └─ /vibing-with-ntm  ← NTM + Agent Mail + Beads coordination
          └─ /OrchestratorSwarm  ← full orchestrator (this repo)
```
| Layer | Skill | Repo / install |
|-------|-------|----------------|
| 1. Machinery | **NTM** | [github.com/Dicklesworthstone/ntm](https://github.com/Dicklesworthstone/ntm) |
| 2. Coordination | **vibing-with-ntm** | Bundled in ACFS or install as skill |
| 3. Orchestration | **OrchestratorSwarm** | **This repo** |

**Rule:** All tmux pane operations go through NTM. OrchestratorSwarm never replaces NTM — it *uses* it.

---

## Core Flywheel tools

| Tool | Role in swarm | Install |
|------|---------------|---------|
| **ntm** | Spawn mixed cc/cod/gmi panes, send marching orders, robot snapshot | `curl … \| bash` from ntm repo |
| **br** (beads_rust) | Issue tracker, bead claim/close, JSONL sync | [beads_rust](https://github.com/Dicklesworthstone/beads_rust) |
| **bv** | Graph triage, bottlenecks, `--robot-next` | ships with beads_rust |
| **Agent Mail** | File reservations, inbox, conflict prevention | [mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail) |
| **/loop** | Autonomous 3-minute orchestrator ticks | Cursor/Claude loop skill |

---

## Agent types (pane prefixes)

| Prefix | Agent | Skill syntax |
|--------|-------|--------------|
| `cc` | Claude Code | `/skill-name` |
| `cod` | Codex CLI | `$skill-name` |
| `gmi` | Gemini CLI | `/skill-name` |

OrchestratorSwarm dispatches **literal first lines** (`/agent-mail`, `/ce-work`, …) — prose-only skill lists do not invoke skills.

---

## Global config paths

Set these for your environment (Flywheel VPS defaults in parentheses):

| Variable | Purpose | Flywheel default |
|----------|---------|------------------|
| `$GLOBAL_AGENTS.md` | Operator-wide agent rules | `/data/projects/AGENTS.md` |
| `~/.claude/CLAUDE.md` | Global Claude instructions | symlink to agent-globals |
| `~/.config/orchestrator-swarm/` | Skill customizations | optional |

Project rules in `<repo>/AGENTS.md` **override** global and skill defaults.

---

## Typical session flow

```text
1. Plan work → PRD in docs/work/ or MEMORY/WORK/  (before swarm)
2. br ready / bv --robot-triage                   (pick backlog)
3. ntm spawn myproject --cc=3 --cod=2 --gmi=1     (panes)
4. Agent Mail preflight + register panes
5. /OrchestratorSwarm — dispatch roles             (this skill)
6. /loop 3m … continue swarm execution              (autonomous ticks)
7. Reality-check digest ~every 16 min
8. Saturation → VERIFY → LEARN → stop loop
```
---

## Related repos

- [agentic_coding_flywheel_setup](https://github.com/Dicklesworthstone/agentic_coding_flywheel_setup) — VPS bootstrap, installs ntm/br/bv/mail
- [ntm](https://github.com/Dicklesworthstone/ntm) — Named Tmux Manager
- [beads_rust](https://github.com/Dicklesworthstone/beads_rust) — issue tracker (`br`)
- [mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail) — multi-agent coordination
- [coding_agent_session_search](https://github.com/Dicklesworthstone/coding_agent_session_search) — CASS (optional memory)

---

## Without full Flywheel

Minimum viable stack:

- tmux + one coding CLI
- ntm (strongly recommended)
- A task list (Beads/br ideal; GitHub issues possible with adapted prompts)

Skip or stub: Agent Mail (use manual file coordination), PRD/ISC workflow (use single goal doc), CASS/CM (use git log + `docs/solutions/`).
