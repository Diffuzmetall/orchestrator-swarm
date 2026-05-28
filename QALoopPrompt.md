# QA self-loop

Повторяющийся чеклист для **QA/E2E** pane.

## Интервал

- **~6 минут** между запусками (как reviewer), или после завершения короткого smoke-прогона.
- Не рви длинный Playwright/browser сценарий посередине — self-loop в конце сценария или на fail/success boundary.

## Синтаксис скиллов

| CLI | Префикс |
| --- | --- |
| `cc` / `gmi` | `/` |
| `cod` | `$` |

## Процедура

```text
/qa-self-loop

Ты QA. Self-loop (~6 мин). По порядку:
1. Перечитай `QALoopPrompt.md`, шаблон QA в `RolePrompts.md`, и **`RulesRefresh.md`** — **полный** refresh AGENTS/CLAUDE (проект + глобальный) **каждый self-loop (~6 min)**. Проверь dev URL / команды из marching order.
2. Agent Mail: новый QA marching-order? ack_required? blockers от workers?
3. **Память (CM + CASS) — recall перед прогоном flow:** `cm context "<flow> QA <project>" --json`; `cass search "<flow> flaky" --json`. Repro recipe → PRD Verification + `/ce-compound`.
4. **Локальный подбор QA-скилла (ms):** `ms search "<flow или симптом>" --robot` если flow нестандартный (Electron app, OAuth с device-code, mobile-RN, и т.п.) — может быть локальный специализированный скилл сверх `e2e-testing-for-webapps`/`agent-browser`. Дефолтный bundle из QA Routing (`SkillRouting.md`) остаётся обязательным.
5. Если прогон в процессе — console/network чистые? Нужен ли defect bead?
6. Если **нет** активного сценария и пустой inbox: Mail ещё раз, затем короткий статус orchestrator («QA свободен, жду assign»). Не парковаться у пустого prompt.
7. Напоминание: буквальные первые вызовы `<prefix>agent-mail`, `<prefix>cass-memory`, `<prefix>context-search` (если в marching order), `<prefix>agent-browser`, `<prefix>e2e-testing-for-webapps` или то, что задал orchestrator. После стабильного UI/smoke по **React/Next**‑части: **`<prefix>react-doctor`** на том же корне/`-project`, что CI (режим `--diff`), затем финальный PASS только если нет регресса скора и критичных `error`.
8. **Закрытие clawpatch finding после worker-патча (если assign на тебе):** `clawpatch show --finding <id>` → выполнить suggested validation (тесты/скрипты из evidence) → `clawpatch revalidate --finding <id>` → `clawpatch triage --finding <id> --status fixed` (или `false-positive --note "<обоснование>"`). Validation статус `uncertain` после `revalidate` — это **не PASS**, ещё один прогон или возврат worker'у. Никогда не запускай `clawpatch fix` — это worker.
9. Findings → новые beads, не silent fail.
```
См. `RolePrompts.md` (QA Output / после Output), `Gotchas.md`.
