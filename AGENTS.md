# AGENTS.md — OrchestratorSwarm

Guidelines for AI agents using this skill repository.

## What this repo is

A **portable agent skill** (not a runtime library). Install with `./install.sh` into `~/.claude/skills/OrchestratorSwarm/`.

## Prerequisites

Read `docs/ECOSYSTEM.md` before operating a swarm:

- [NTM](https://github.com/Dicklesworthstone/ntm) — required for pane management
- [beads_rust](https://github.com/Dicklesworthstone/beads_rust) — `br` / `bv` for backlog
- [mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail) — coordination
- `/vibing-with-ntm` skill — coordination layer below this skill

## Entry point

```
/ntm → /vibing-with-ntm → /OrchestratorSwarm
```
Use **OrchestratorSwarm** only when you need full multi-role orchestration (workers + reviewers + QA, looper, reality-check). For simple tmux send/spawn, use `/ntm` alone.

## Key files

| File | When to read |
|------|--------------|
| `SKILL.md` | Triggers, constraints, workflow table |
| `OperatingProcedure.md` | Start swarm, preflight, dispatch |
| `LoopPrompt.md` | Every ~3 min looper tick |
| `RolePrompts.md` | Marching orders per role |
| `AlgorithmIntegration.md` | PRD / EXECUTE phase sync |
| `AgentMailRunbook.md` | Mail down, orphan panes |
| `docs/ECOSYSTEM.md` | Flywheel tool chain |

## Policies carried into target repos

When executing in a **project repo**, that repo's `AGENTS.md` wins. This skill adds:

- main-only, no worktrees (unless target repo explicitly allows)
- literal skill invocation lines in dispatch
- tmux capture-pane ground truth (not just NTM Activity)
- separate worker / reviewer / QA roles

## Optional extensions

- `optional-extensions/MemoryIntegration-PAI.md` — full PAI/CASS/CM stack
- `~/.config/orchestrator-swarm/PREFERENCES.md` — operator overrides

## Safety

- Never store secrets in beads, PRD, or Agent Mail bodies
- Never force-push main
- Never delete files without explicit user permission (follow target repo AGENTS.md)
