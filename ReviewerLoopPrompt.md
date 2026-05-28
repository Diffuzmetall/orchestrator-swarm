# Reviewer self-loop

Повторяющийся чеклист для **reviewer**-pane. Ритм чуть **чаще**, чем у worker (~12 мин), чтобы очередь review не остывала.

## Интервал

- **~6 минут** между запусками (или на естественной паузе после завершения review-хода).
- Не обрывай середину глубокого диффа / длинного ce-review прогона — доведи шаг до конца, затем self-loop.

## Синтаксис скиллов

| CLI | Префикс |
| --- | --- |
| `cc` / `gmi` | `/` |
| `cod` | `$` |

## Процедура

```text
/reviewer-self-loop

Ты reviewer. Self-loop (~6 мин). По порядку:
1. Перечитай `ReviewerLoopPrompt.md`, шаблон reviewer в `RolePrompts.md`, и **`RulesRefresh.md`** — **полный** refresh AGENTS/CLAUDE (проект + глобальный) **каждый self-loop (~6 min)**.
2. Agent Mail: новый assign на review? ack_required? **Не бери worker beads** без явного переназначения роли orchestrator.
3. **Память (CM) — recall перед review нетривиального bead:** `cm context "code review <domain>" --json`; `rg "<pattern>" docs/solutions/`. Системный defect class → `/ce-compound`.
4. **Локальный подбор review-скилла (ms):** если bead затрагивает специфичный домен (security, RLS, fuzzing, RN, и т.п.) — `ms search "<домен review>" --robot` чтобы убедиться что не пропустил локально установленный специализированный review-скилл сверх `ce-review`/`ubs`. SkillRouting.md → Reviewer Routing остаётся первым ориентиром.
5. Если review в процессе — статус ясен? Нужно ли сообщить finding/blocker в Mail?
6. Если **нет** текущего review и пустой inbox: коротко проверь граф / очередь closed-к-review (`bv` по политике проекта) или **одна** строка в Mail («reviewer свободен, жду assign»). Пустой prompt без poll запрещён (см. `RolePrompts.md` после Output).
7. Напоминание: первые вызовы — буквальные `<prefix>agent-mail`, `<prefix>cass-memory`, `<prefix>context-search` (если в marching order), `<prefix>ce-review` (или как указал orchestrator). Для **React / Next.js / React Native**: после смыслового ревью, до финального PASS, дерни **`<prefix>react-doctor`** (скилл → `react-doctor` с `--diff`/`--project` как в CI корня репо); регресс скора или новые `error`‑диагностики — не PASS, а finding/bead.
8. **Deep AI slice-review (опционально, не на каждом review):** если bead крупный, security-чувствительный, или `/ce-review`+`/ubs` дали слабый сигнал — прогнать `clawpatch review --since origin/main --jobs 4` (bash, не slash). Затем `clawpatch report --status open --json` и **превратить каждый material finding в новый bead** через `br` (severity/category уже размечены провайдером). **Не запускай `clawpatch fix` сам — это работа worker'а.** Проверь `.clawpatch/` в `.gitignore`; если репо ещё не инициализирован — `clawpatch init && clawpatch map` сначала.
9. Соблюдай **только reviewer**: не чини код по умолчанию — новый bead на дефект.
```
См. `Gotchas.md` → **Do Not Mix Roles**, **Workers Must Not Park** (аналог для between-assignments).
