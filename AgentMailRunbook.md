# Agent Mail — Runbook For Orchestrators

Use with `/agent-mail`. This file complements `OperatingProcedure.md` when Agent Mail is flaky, restarted, or swarm panes are “orphaned” (working code, but no identity / reservations / inbox).

## Why This Matters

Without a live Agent Mail session, panes lose **file reservations**, **inbox**, and **ack threads**. The swarm can still edit files and create merge conflicts. Treat mail like a control plane: fix or explicitly fail open only with user approval.

## Every Pane: Session Bootstrap

At the start of each agent session on a repo that uses Agent Mail, follow `/agent-mail`:

- Call `macro_start_session(human_key="/abs/path/to/project", ...)` (or equivalent register + inbox fetch).
- Before edits: `file_reservation_paths` → work → `release_file_reservations` when done.

If bootstrap was skipped or MCP disconnected mid-session, the pane is **not registered** until it runs bootstrap again.

## Health Checks (Orchestrator / Looper)

1. **HTTP** (daemon listening):

   ```bash
   curl -sS http://127.0.0.1:8765/health
   ``

   Expect a JSON body with healthy status (not connection refused).

2. **Doctor** (data integrity, stale reservations, index):

   ```bash
   am doctor check --verbose
   ``

   If `am` is missing:

   ```bash
   uv run python -m mcp_agent_mail.cli doctor check --verbose
   ``

3. **MCP client**: After a **server restart**, IDEs/clients may still show “connected” briefly or reconnect with errors. Confirm a fresh tool call succeeds (e.g. `fetch_inbox` or `macro_start_session`) — not only `/health`.

## Symptom → Likely Cause → Action

| Symptom | Likely cause | Action |
| --- | --- | --- |
| Connection refused / cannot reach `127.0.0.1:8765` | Daemon not running | Start server (`am` or install docs in `/agent-mail`); recheck `/health`. |
| Socket error, reset, or MCP handshake failures right after a change | **Transient restart window**; clients caught mid-flight | Wait for `/health` OK; **re-bootstrap every pane** (`macro_start_session`). |
| `sender_name not registered` | Pane never bootstrapped, or session cleared after restart | Run `macro_start_session` (or `register_agent`) in that pane. |
| HTTP 401 / auth errors on MCP | **Bearer token mismatch** between server and Claude/Cursor MCP config | Align token per `/agent-mail` → `references/INSTALL.md` / `references/FIX-MCP-CONFIG.md`. **Do not paste tokens into beads, PRs, or memory bodies** — record “token drift / fix config” without the secret. |
| `FILE_RESERVATION_CONFLICT` | Overlap or stale holder | Coordinate via `send_message`, wait for TTL, or `exclusive=false` per `/agent-mail`. |
| Doctor reports stale FTS / orphan data | Interrupted writes or crash | `am doctor repair --dry-run` then `am doctor repair --yes`; re-check `doctor check`. |
| Errors or logs mention **malformed**, **`idx_agents_*`**, or index corruption; `doctor repair` does not fix it | Abrupt shutdown, disk issues, or partial writes — **ordinary repair is not always enough** | See **Index reconstruct** below: **stop service first**, then `doctor reconstruct`. |
| `database is locked` | Concurrent doctor/CLI vs server | Brief wait; restart daemon if stuck; retry. |

## Index Reconstruct (`idx_agents_*`, Malformed Index)

After restarts, crashes, or disk turbulence you may see **malformed** messages or broken **`idx_agents_*`** (or similar index corruption). **`am doctor repair` alone is sometimes insufficient.**

**Procedure (order matters):**

1. **Stop the Agent Mail service/daemon** (no concurrent writers; use your env’s stop: service manager, `am` shutdown, or kill PID you own).
2. Optionally preview: `am doctor reconstruct --dry-run` (or `uv run python -m mcp_agent_mail.cli doctor reconstruct --dry-run`).
3. Apply: `am doctor reconstruct --yes` (or `uv run … doctor reconstruct --yes`).
4. **Start** Agent Mail again; confirm `curl …/health` and `am doctor check --verbose`.
5. **Re-bootstrap every pane** (`macro_start_session`) — same as after any hard recovery.

Do not run `reconstruct` against a live busy server if your environment docs say otherwise; the critical rule is **no service writing the same DB while reconstruct runs** — hence **stop first**.

## Recovery Ladder (Order Matters)

1. `curl …/health` — server up.
2. `am doctor check --verbose` — understand issues.
3. `am doctor repair --dry-run` → `am doctor repair --yes` if safe; re-check `doctor check`.
4. If symptoms match **malformed / `idx_agents_*`** or repair did not clear corruption: follow **Index reconstruct** above (stop service → `doctor reconstruct` → start → check → re-bootstrap panes).
5. If still broken: **restart Agent Mail daemon** (use your environment’s standard: `am`, installer script, or service). Re-run `/health` + `doctor check`.
6. If MCP still fails: fix HTTP URL + **Authorization** header per `references/FIX-MCP-CONFIG.md` (token sources: env, server `.env`, Claude config — **never log full tokens**).
7. **Swarm recovery**: send each pane a short `ntm` message: “Server healthy — run `/agent-mail` bootstrap: `macro_start_session` for this repo now.”

## Orphan Pane Detection (Multi-Pane Swarms)

After **any** Agent Mail restart or MCP outage:

- Expected: **every** worker, reviewer, and QA pane has completed a successful bootstrap for the **same** `human_key` (repo path).
- Compare **NTM/tmux pane count** (non-orchestrator, by role) to **registered agents** for that project (via MCP resource `resource://agents/{project_key}` or project docs — exact CLI may vary by install).

If counts diverge: treat missing panes as **coordination-unhealthy** — dispatch re-bootstrap only (high-signal); do not assume reservations exist until bootstrap succeeds.

## Coordination After Recovery

- One short broadcast or targeted `ntm send` per lost pane: re-run `macro_start_session`, then continue the current bead with reservations.
- Do not spam progress noise; include: repo path, bead id if any, “bootstrap Agent Mail now”.

## Memory (Cass / cm / PAI)

Persist **operational** lessons only (Edit PRD `## Decisions`, `/ce-compound`, or Mail — см. **`MemoryIntegration.md`**):

- OK: “After Agent Mail PID change at HH:MM, all panes needed `macro_start_session`; symptom was socket error during restart window.”
- Not OK: bearer tokens, full `settings.json` snippets, or any secret.

Use `/cass`, `/cass-memory`, `/context-search`, `/ce-compound`, or `/cm` as available.

## References

- Full tool and workflow detail: `~/.claude/skills/agent-mail/SKILL.md`
- Doctor / backup / repair depth: `~/.claude/skills/agent-mail/references/RECOVERY.md`
- Install, port, token env: `~/.claude/skills/agent-mail/references/INSTALL.md`
- Claude MCP HTTP fix: `~/.claude/skills/agent-mail/references/FIX-MCP-CONFIG.md`
