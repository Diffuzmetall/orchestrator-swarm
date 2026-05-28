# Skill Routing

The general orchestrator chooses the baseline skill bundle for every pane. Agents may run `ms search "query" --robot` for additional context, but the orchestrator must not assume they will pick the right workflow alone.

**Invocation:** when dispatching, list skills as **literal `/name` or `$name` lines** in `RolePrompts.md` → **ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ**. A prose-only "Skills:" sentence does not trigger Claude Code skill loading or Codex `$` commands.

**Codex (`cod`) complex beads:** after `$agent-mail`, add **`/goal`** (Codex slash command) with a structured measurable brief (criteria = atomic checkboxes, aligned with **ISC-style** criteria in `GoalDispatch.md`). Full template: `GoalDispatch.md`.

## Missing Skill Fallback

If the exact desired skill is unavailable, not installed, or `ms search` returns no useful result, do not block the swarm.

Fallback order:

1. Pick the closest semantically appropriate skill from the tables below.
2. If no domain-specific skill fits, use a general workflow:
   - implementation: `/ce-work`
   - debugging: `/ce-debug` or `/diagnose`
   - review: `/ce-review` or `/ubs`
   - React/Next/RN quality gate (review or post-QA): `/react-doctor`
   - QA/browser: `/e2e-testing-for-webapps` or `/test-browser`
   - planning/docs: `/beads-workflow` or `/reality-check-for-project`
3. Continue work; create a follow-up note only if the missing skill is repeatedly needed.

Do not invent skill names. Choose by meaning, then adapt syntax to pane type.

## Goal-First Work And Tests (Not Test Theater)

- **Ship the bead outcome** first: the graph and reviewers care about **done + correct**, not the number of test files.
- Add, extend, or fix **tests that buy real confidence**: regressions for bugs you fixed, public contracts, critical paths the bead touches. **Do not** grow large suites “because best practice” when the bead does not require it.
- When choosing what to do next or whether you are on the critical path, use **graph triage**, not gut feel: `bv --robot-triage --format toon`, `bv --robot-next`, `br ready --json` as the repo documents — and load **`/beads-bv`** (**`$beads-bv`** on Codex) when you need the full workflow. Find **bottlenecks** (blocked, stalled, highest leverage) and work **toward unblocking / closing the bead**, not toward maximal LOC in `*.test.*`.
- Reviewers may still ask for missing coverage on **material** risk; that is not an invitation to blanket tests.

## Memory And Local Skill Discovery (применяется на всех уровнях)

**Hindsight отключён.** Полная карта: **`MemoryIntegration.md`** → раздел **«Пара recall: `/cass-memory` + `/context-search`»**.

| Когда | READ (recall) | WRITE (retain) |
| --- | --- | --- |
| **Rules refresh (AGENTS + CLAUDE)** | **`RulesRefresh.md`** — global + project; orchestrator every looper tick; roles every self-loop | — |
| **Перед** non-trivial bead/review/QA | **`/cass-memory`** (всегда) + `cm context "<task>" --json`; **`/context-search <topic>`** когда нужен **исторический** контекст (триггеры в MemoryIntegration); `rg "<topic>" docs/solutions/` | — |
| **После** не-очевидного открытия | — | Edit PRD `## Decisions`; `/ce-compound` если командный урок |
| **Orchestrator recovery / spawn** | **`/context-search`** + `cm context`; при drill-down — `cass search` | Edit PRD `## Decisions` |
| **LEARN (swarm close)** | Read PRD | `algorithm-reflections.jsonl`; optional `/ce-compound` |
| **Локальный скилл** | `ms suggest --cwd <repo>`; `ms search "<topic>" --robot` | — |
| **Session archaeology (узкий)** | `/cass` / `cass search … --json` | — |

**Порядок literal lines:** `/agent-mail` → **`/cass-memory`** → **`/context-search`** (если orchestrator включил) → workflow skill. Bash после `/cass-memory`: `cm context "<task>" --json`.

**cm vs context-search (не путать):**
- **`cm context`** — процедурные правила, anti-patterns, playbook
- **`/context-search`** — что уже делали: PRD/WORK, git, sessions, prompts

**Anti-patterns:**
- cm context выдал antiPattern по проекту → игнорировать;
- закрыл bead с не-очевидным fix → не Edit PRD / ce-compound;
- пропустить `ms suggest` в незнакомом домене;
- использовать `/find-skills` для локальных скиллов (нужен `ms`).

## Global Skill Matrix

| Phase / situation | Skills |
| --- | --- |
| Raise and operate swarm | `/ntm`, `/vibing-with-ntm`, `/multi-agent-swarm-workflow` |
| **Rules stay hot (AGENTS + CLAUDE)** | **`RulesRefresh.md`** — orchestrator: every looper tick; worker/reviewer/QA: every self-loop |
| Coordination, file locks, overlap, inbox | `/agent-mail`, `/multi-agent-coordination` |
| **Memory recall before non-trivial work** | **`/cass-memory`** + `cm context`; **`/context-search`** (paired, see MemoryIntegration); `cass search`; `docs/solutions/` |
| **Retain non-obvious lesson** | Edit PRD `## Decisions`; `/ce-compound` → `docs/solutions/` |
| **Local skill discovery for new bead/role (мета-скилл)** | `ms suggest --cwd <repo>`, `ms search "<query>" --robot`, `ms show <name>`, `ms load <name>` — НЕ `/find-skills` (та ставит внешние) |
| Install new skill from external registry (не для local discovery) | `/find-skills` |
| Agent Mail down, MCP blip, orphan panes, doctor repair, token/config drift | `/agent-mail` + `AgentMailRunbook.md` in this skill |
| Agent replacement and role redistribution | `/agent-fungibility-philosophy` |
| Beads triage, next task, dependency graph | `/beads-bv`, `bv --robot-triage`, `bv --robot-next`, `/beads-br` |
| Convert plans to beads | `/beads-workflow` |
| Work from plan or prompt | `/ce-work` with explicit no-worktree override |
| Debug / root cause | `/ce-debug`, `/diagnose`, `/debug-agent` |
| Fast bug scan after implementation | `/ubs`, `/ubs-workflow` |
| Deep audit / pre-release hardening | `/multi-pass-bug-hunting` |
| Code review before PR | `/ce-review`, `/ce-code-review` |
| **Semantic feature-slice review + explicit, finding-scoped AI patches** | `clawpatch` CLI (bash): `clawpatch init && clawpatch map && clawpatch review --since origin/main --jobs 4 && clawpatch report --status open --json`. Не slash-скилл. Findings durable в `.clawpatch/findings/`, провайдер по умолчанию `codex`, для Claude — `--provider acpx --model claude:<...>`. **`.clawpatch/` обязательно в `.gitignore`**. См. INSTRUCTIONS.md → Clawpatch (`clawpatch`). |
| Document / plan review | `/document-review`, `/ce-doc-review` |
| Registration, auth, onboarding, chat, audit critical flows | `/e2e-testing-for-webapps`, `/test-e2e-webapps` |
| Browser automation / frontend QA (mandatory gate) | `/agent-browser` — `open` → `snapshot -i` → `@eN` refs → `console` |
| Manual browser smoke / console / network | `/agent-browser`, `/vibecoding-frontend-browser-qa`, `/test-browser` |
| Real integrations without mocks | `/testing-real-service-e2e-no-mocks` |
| Parser/protocol/serialization robustness | `/testing-fuzzing` |
| Stub/mock/TODO/fake-code audit | `/mock-code-finder` |
| Reality check against README/plan vision | `/reality-check-for-project` |
| System pressure / stuck builds / tmux sprawl | `/system-performance-remediation` |
| Disk pressure | `/sbh` |
| Remote/offloaded builds | `/rch` |
| Commit | `/git-commit`, `/ce-commit` if available |
| Commit + PR | `/git-commit-push-pr`, `/ce-commit-push-pr` if available |
| Lessons learned | `/cass-memory`, `/ce-compound`, `/context-search`, PRD `## Decisions` |
| Architecture review / module refactoring | `/improve-codebase-architecture` |
| Domain model / ADR alignment check | `/grill-with-docs` |

## Worker Routing

| Bead type | Required skill bundle |
| --- | --- |
| Normal implementation task | `/ce-work`, `/beads-br`, `/beads-bv` |
| Bugfix with reproducible symptom | `/ce-debug`, then `/ce-work` |
| Mastra/runtime/API | `/mastra`, `/ce-work`, `/testing-real-service-e2e-no-mocks` for integrations |
| Frontend/UI | `/ce-work`, `/vibecoding-frontend-browser-qa`, plus `/e2e-testing-for-webapps` for critical flows |
| Auth/registration/onboarding | `/ce-work`, `/e2e-testing-for-webapps`, `/testing-real-service-e2e-no-mocks` |
| DB/schema/RLS/migrations | `/database-migration-expert`, `/ce-work`, `/testing-real-service-e2e-no-mocks` |
| Parser/protocol/serialization | `/testing-fuzzing`, `/ce-work` |

## Reviewer Routing

| Risk / area | Required skill bundle |
| --- | --- |
| Normal code review | `/ce-review` or `/ce-code-review` |
| React/Next/RN — diff health before PASS | `/react-doctor` (`--diff`, monorepo: `--project` как в CI) |
| AI-generated code bug risk | `/ubs`, `/ubs-workflow` |
| **Deep AI review на изменённом slice (между `/ce-review` и `/multi-pass-bug-hunting`)** | `clawpatch review --since origin/main --jobs 4` (bash, не slash). Findings → беды через `clawpatch report --status open --json`. Severity / category уже размечены провайдером. Безопасно: review не пишет в код, только в `.clawpatch/`. |
| Deep saturation audit | `/multi-pass-bug-hunting` |
| Security/auth/public endpoints | `/security-auditor`, `/security-hardening` |
| DB/RLS/migrations | `/database-migration-expert`, `/data-integrity-guardian` if available |
| Frontend/browser behavior | `/vibecoding-frontend-browser-qa`, `/test-browser` |
| Fake/stub/TODO risk | `/mock-code-finder` |
| README/plan alignment | `/reality-check-for-project` |
| Architecture / module boundaries / refactoring | `/improve-codebase-architecture` |
| Unclear bug root cause found during review | `/diagnose` |
| Domain model / glossary / ADR alignment during review | `/grill-with-docs` |
| Test quality audit (behavior vs implementation, no mock internals) | `/tdd` |

## QA Routing

**`/agent-browser` обязателен для любого UI/browser QA** (требование CLAUDE.md). Запускать через `agent-browser` CLI: `open` → `snapshot -i` → взаимодействие по `@eN` refs → `console` / `network` проверки. Использовать до объявления фронтенд-задачи выполненной.

| Flow | Required skill bundle |
| --- | --- |
| Registration/auth/onboarding | `/agent-browser`, `/e2e-testing-for-webapps`, `/testing-real-service-e2e-no-mocks` |
| Chat UI and streaming | `/agent-browser`, `/e2e-testing-for-webapps`, `/vibecoding-frontend-browser-qa` |
| Audit launch/report flow | `/agent-browser`, `/e2e-testing-for-webapps`, `/test-browser` |
| Visual/browser smoke after UI changes | `/agent-browser`, `/vibecoding-frontend-browser-qa`, `/test-browser` |
| Real services without mocks | `/testing-real-service-e2e-no-mocks` |
| Any frontend-affecting change (mandatory gate) | `/agent-browser` — `open` → `snapshot -i` → interact → `console` |
| Verify acceptance criteria expressed as behavioral tests | `/tdd` |
| React/Next/RN — score/architecture regressions after E2E/smoke | `/react-doctor` (`--diff` от базовой ветки) |
| **Revalidate / triage clawpatch finding после worker-патча** | `clawpatch show --finding <id>` (evidence + suggested validation) → прогнать suggested-checks → `clawpatch revalidate --finding <id>` → `clawpatch triage --finding <id> --status fixed\|false-positive --note "<...>"`. Не запускать `clawpatch fix` самостоятельно — это работа worker'а. |

## Pane Syntax

| Pane | Skill syntax | Example |
| --- | --- | --- |
| `cod` / Codex | `$skill-name` | `$ce-review`, `$react-doctor`, `$testing-fuzzing` |
| `cc` / Claude Code | `/skill-name` | `/ce-review`, `/react-doctor`, `/e2e-testing-for-webapps` |
| `gmi` / Gemini | `/skill-name` | `/ce-review`, `/react-doctor`, `/e2e-testing-for-webapps` |

Wrong syntax means the skill will not load. Always adjust the bundle to pane type before `ntm send`.
