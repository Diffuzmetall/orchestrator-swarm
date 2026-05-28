# Memory Integration (Core + Optional Extensions)

OrchestratorSwarm works **without** a personal memory stack. The core loop relies on:

- repo `AGENTS.md` / `CLAUDE.md` (see `RulesRefresh.md`)
- Beads issue state (`br`, `bv`)
- Agent Mail coordination
- PRD / work artifacts under `docs/work/` or `MEMORY/WORK/` (see `AlgorithmIntegration.md`)
- `docs/solutions/` team learnings (if your repo uses them)

**Optional extensions** (install separately if you use the Flywheel stack):

| Extension | Skill / CLI | When to use |
|-----------|-------------|-------------|
| Session archaeology | [CASS](https://github.com/Dicklesworthstone/coding_agent_session_search) + `/cass-memory` | Prior prompts, incident patterns |
| Historical context | `/context-search` or `cass search` | "What did we try before on X?" |
| Procedural playbooks | `cm context` (CM) | Non-trivial beads, recovery |
| Compound learnings | `/ce-compound` | After non-obvious fixes |
| Full PAI memory stack | `optional-extensions/MemoryIntegration-PAI.md` | Flywheel / PAI operators only |

---

## Core recall (always available)

Before non-trivial dispatch, recovery, or reality-check:

```bash
# Project learnings (if present)
rg -l "<topic>" docs/solutions/ 2>/dev/null | head -5

# Git history for the area
git log --oneline -10 -- '<paths touched by bead>'

# Bead + graph context
br show <id> --json
bv --robot-triage --format toon
```
After recovery or a non-obvious fix:

- Edit PRD `## Decisions` (see `AlgorithmIntegration.md`)
- Optionally append to `docs/solutions/` if your team uses that pattern

---

## Optional: paired recall (CASS + Context Search)

If you have CASS and Context Search installed (common on [Agentic Coding Flywheel](https://github.com/Dicklesworthstone/agentic_coding_flywheel_setup) VPS):

**Order on worker/reviewer/QA dispatch:**

```
/agent-mail
/cass-memory          ← if installed
/context-search …     ← when historical context needed
/<workflow-skill>
```
After `/cass-memory`: `cm context "<task>" --json`

### When to add `/context-search`

| Trigger | Example topic |
|---------|---------------|
| Unfamiliar subsystem | `<project> auth middleware` |
| Bead references past incident | `<project> agent mail recovery` |
| Orchestrator recovery | `<symptom> ntm swarm stall` |

Full Flywheel/PAI map: `optional-extensions/MemoryIntegration-PAI.md`

---

## LEARN (swarm close)

When backlog saturates or the operator stops the swarm:

1. Final VERIFY pass against PRD criteria (`AlgorithmIntegration.md`)
2. Append one line to `docs/swarm-learnings/reflections.jsonl` (create dir if needed)
3. Optional: `/ce-compound` for team-visible learnings

```json
{"ts":"2026-05-28T12:00:00Z","repo":"myproject","lesson":"…","beads_closed":12}
```
---

## Anti-patterns

- Closing beads without checking pane recap + disk artifacts (`PaneRecapReading.md`)
- Skipping PRD `## Decisions` after recovery
- Using `/find-skills` when you meant local `ms search` (different tools)
