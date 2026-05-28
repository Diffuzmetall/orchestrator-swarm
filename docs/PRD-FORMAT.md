# PRD Format (for OrchestratorSwarm)

OrchestratorSwarm executes against an **existing** PRD — it does not invent project goals. Create the PRD during planning; the swarm runs the EXECUTE phase.

**Search paths (first match wins):**

```bash
ls -t docs/work/*/PRD.md MEMORY/WORK/*/PRD.md 2>/dev/null | head -5
```
---

## Frontmatter template

```yaml
---
task: "Short description of the work session"
phase: plan          # plan | build | execute | verify | learn | complete
progress: 0/5        # ISC items done / total
updated: 2026-05-28T12:00:00Z
iteration: 1
---
```
---

## Body sections

```markdown
## Criteria

- [ ] ISC-1: Measurable outcome (verifiable on disk or in tests)
- [ ] ISC-2: …

## Context

Background, links, constraints.

## Plan

High-level approach (beads may refine).

## Decisions

Incident log: what happened, what we chose (no secrets).

## Verification

Evidence from reality-check digests and final VERIFY.
```
---

## Phase lifecycle with swarm

| Phase | Who | What |
|-------|-----|------|
| plan / build | Human or planning skills | Create PRD, decompose to beads |
| **execute** | **OrchestratorSwarm** | Looper, dispatch, bead closes → `[x]` ISC |
| verify | Orchestrator + reviewers | Reality-check sub-passes + final VERIFY |
| learn | Orchestrator | Reflections JSONL, optional compound docs |
| complete | — | PRD frozen; new iteration needs `iteration: N+1` |

See `AlgorithmIntegration.md` for mapping bead closes → ISC updates.
