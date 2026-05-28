# Customization

Override OrchestratorSwarm defaults without forking the repo.

## Config directory

```text
~/.config/orchestrator-swarm/
├── PREFERENCES.md      # Free-form overrides (loaded first)
├── role-mix.yaml       # Optional default worker/reviewer/QA counts
└── hooks/              # Optional shell hooks
```
Create the directory:

```bash
mkdir -p ~/.config/orchestrator-swarm
```
## PREFERENCES.md example

```markdown
# My swarm preferences

- Default looper interval: 3m (keep default)
- Global AGENTS path: /data/projects/AGENTS.md
- Skip optional CASS memory when cm is not installed
- AFK stall threshold: 8 loops (default 6)
```
## Project-level overrides

These always win over skill defaults:

| File | Purpose |
|------|---------|
| `<repo>/AGENTS.md` | Project agent rules |
| `<repo>/CLAUDE.md` | Project Claude rules |
| `<repo>/.ntm/pipelines/` | NTM pipeline YAML for stable flows |

## Flywheel / PAI operators

If you run the full PAI stack, copy patterns from:

`optional-extensions/MemoryIntegration-PAI.md`

Point `$GLOBAL_AGENTS.md` at your VPS root AGENTS (see `docs/ECOSYSTEM.md`).
