# Rules Refresh (AGENTS.md + CLAUDE.md)

Долгий swarm **сжимает контекст** — правила из AGENTS/CLAUDE выпадают из «рабочей памяти» агента. Это **обязательная SOP** для orchestrator и **всех** ролей (worker, reviewer, QA): периодически **перечитывать** глобальные и проектные правила, не полагаться на «прочитал в начале сессии».

> Repo-local rules **перебивают** generic skill/NTM советы. После refresh — следуй проекту, затем глобальному слою.

---

## Какие файлы (читай то, что **существует**; пропускай отсутствующие)

| Слой | AGENTS.md | CLAUDE.md |
| --- | --- | --- |
| **Глобальный (operator)** | `$GLOBAL_AGENTS.md` (see `docs/ECOSYSTEM.md`; Flywheel VPS: `/data/projects/AGENTS.md`); fallback: `$HOME/AGENTS.md` | `~/.claude/CLAUDE.md` |
| **Проектный (текущий repo swarm)** | `<repo>/AGENTS.md` | `<repo>/CLAUDE.md` |

`<repo>` = абсолютный путь checkout, на котором работает swarm (тот же, что в `macro_start_session` / marching order).

**Не путать:** `README.md` — полезен при старте, но **не заменяет** AGENTS/CLAUDE refresh.

---

## Кадence (когда перечитывать)

| Роль | Интервал | Что читать |
| --- | --- | --- |
| **Orchestrator** | **Каждый looper-тик (~3 min)** | **Проект:** `AGENTS.md` + `CLAUDE.md` |
| **Orchestrator** | **Каждый ~3-й looper-тик** и **каждый reality-check digest (~16 min)** | **+ Глобальный:** `$GLOBAL_AGENTS.md` (see `docs/ECOSYSTEM.md`) + `~/.claude/CLAUDE.md` |
| **Worker** | **Каждый self-loop (~12 min)** | **Полный набор:** проект + глобальный (4 файла, что есть) |
| **Reviewer / QA** | **Каждый self-loop (~6 min)** | **Полный набор:** проект + глобальный |

Дополнительно перечитай **немедленно**, если:
- orchestrator сделал re-dispatch / сменил bead / failover роли;
- в Mail пришло «правила обновились» или merge в `AGENTS.md` / `CLAUDE.md`;
- агент поймал себя на нарушении main-only, beads, safety, commit policy.

---

## Как читать (не формальность)

1. **Read** (или эквивалент) — загрузи содержимое в контекст; не ограничивайся `test -f`.
2. При очень длинных файлах — минимум **первые ~200 строк** + секции Safety / Git / Beads / Agent Mail, если они ниже (grep заголовков).
3. После refresh одной строкой для себя: *какие 1–2 правила критичны для **текущего** bead* (main-only, br sync, no force-push, agent-browser gate, …).
4. **Не спамь Agent Mail** статусом «перечитал AGENTS» — это внутренний discipline step.

---

## Быстрая проверка (orchestrator, bash)

```bash
REPO="<absolute repo path>"
for f in \
  "`$GLOBAL_AGENTS.md` (see `docs/ECOSYSTEM.md`; Flywheel: `/data/projects/AGENTS.md`)" \
  "$HOME/.claude/CLAUDE.md" \
  "$REPO/AGENTS.md" \
  "$REPO/CLAUDE.md"
do
  test -f "$f" && echo "rules: $f ($(wc -l < "$f") lines)"
done
```
Затем **Read** по списку из таблицы cadence для этого тика.

---

## Связанные файлы

| Файл | Где встроено |
| --- | --- |
| `LoopPrompt.md` | Шаг 1 orchestrator looper |
| `LoopAlgorithmAnchor.md` | Чеклист каждого тика |
| `WorkerLoopPrompt.md` / `ReviewerLoopPrompt.md` / `QALoopPrompt.md` | Self-loop |
| `RolePrompts.md` | «Перед стартом» + looper dispatch |
| `OperatingProcedure.md` | First Actions |
| `SKILL.md` | Mandatory constraint |
