# NTM Surface Gaps — недоиспользуемые команды и куда их вставлять

> Дата ввода: 2026-05-17
> Контекст: аудит показал, что 4 группы NTM-команд почти не используются операторами swarm-а, хотя дают высокую отдачу. Этот документ — их runbook **внутри OrchestratorSwarm**.

> **Где это срабатывает:** оркестратор/looper/recovery-проходы. Воркер/ревьювер/QA не зовут эти команды напрямую — это операторские инструменты.

---

## Gap A1 — `ntm pipeline` (durable YAML вместо ручного looper-а)

### Симптом
Looper гоняется руками каждые 3 минуты. Один и тот же sequence действий (snapshot → triage → dispatch → capture-pane → assess) переписывается заново при каждом recovery.

### Решение
Описать повторяющийся flow как `ntm pipeline` YAML. Pipeline durable: переживает рестарт, имеет `status`/`resume`, не зависит от живого looper-а.

### Команды

```bash
ntm pipeline list                                       # доступные YAML
ntm pipeline run .ntm/pipelines/review.yaml --session myproject
ntm pipeline status run-20260517-123456-abcd
ntm pipeline resume run-20260517-123456-abcd            # после рестарта
ntm pipeline cleanup --older=7d
```
### Где встраивать в OrchestratorSwarm
- **OperatingProcedure.md → Quick Start step 7:** если в `.ntm/pipelines/` уже есть подходящий YAML для текущего режима (review/full-stack/red-green) — оператор запускает `ntm pipeline run` вместо ручного диспатча.
- **LoopPrompt.md:** если pipeline уже запущен, looper делает только `ntm pipeline status` + capture-pane проверку, без полного re-dispatch.
- **RecoverStalledWork:** при stall `ntm pipeline resume` дешевле, чем reconstructing state руками.

### Когда **не** использовать
- Когда задача разовая или экспериментальная — pipeline создаёт инерцию.
- Когда нет стабильного flow — pipeline нечего описывать.

---

## Gap A2 — `ntm template` + `ntm session-templates` + `ntm recipes`

### Симптом
Marching orders переписываются от swarm-а к swarm-у. Тот же `RolePrompts.md`-шаблон с подстановкой `/goal` + `/cass-memory` + `ms suggest` — пишется руками каждый раз.

### Решение
- **`ntm template`** — переиспользуемые prompt templates (с переменными).
- **`ntm session-templates`** — целые конфигурации сессии (mix агентов + начальный prompt + worktree-флаги).
- **`ntm recipes`** — высокоуровневые пресеты (`full-stack`, `red-green`, `refactor`).

### Команды

```bash
ntm template list
ntm template show refactor
ntm send myproject -t fix --var issue="nil pointer" --file internal/auth/service.go

ntm session-templates list
ntm session-templates show refactor
ntm recipes list
ntm recipes show full-stack

ntm spawn myproject -r full-stack                       # spawn по recipe
ntm spawn myproject -t red-green                        # spawn по session-template
```
### Где встраивать в OrchestratorSwarm
- **RolePrompts.md:** для worker/reviewer/QA создать соответствующие templates с переменными `{bead_id}`, `{role}`, `{loop_interval}`. После — оркестратор делает `ntm send -t worker --var bead_id=br-123` вместо вставки полного prompt.
- **OperatingProcedure.md → Quick Start step 7:** если recipe/session-template подходит — `ntm spawn -r/-t ...` вместо явного `--cc=5 --cod=2`.
- **GoalDispatch.md:** шаблон `/goal`-prompt с ISC-критериями становится `ntm template show goal-dispatch`.

### Когда **не** использовать
- Одноразовый эксперимент — template создавать дороже, чем написать prompt.
- Сильно нестандартный bead — template усреднит контекст и убьёт точность.

---

## Gap A3 — `ntm rotate` + `ntm quota` (quota-death recovery без смены сессии)

### Симптом
При rate-limit / quota death оператор переключает аккаунты через `caam` глобально. Это убивает текущую tmux-сессию или требует re-spawn panes.

### Решение
- **`ntm quota`** — проверка квот провайдеров до и во время swarm-а.
- **`ntm rotate`** — переключение конкретного pane (или всех cc/cod/gmi) на резервный аккаунт **внутри swarm-а**, без kill.

### Команды

```bash
ntm quota                                               # сводка по всем провайдерам
ntm quota --agent claude --warn=80                      # alert при 80%
ntm rotate myproject --pane=3                           # rotate один pane
ntm rotate myproject --agent=cc                         # rotate все cc-panes
ntm --robot-health-restart-stuck myproject --stuck-threshold 10m
```
### Где встраивать в OrchestratorSwarm
- **AgentMailRunbook.md → Symptom table:** добавить «pane stuck after rate-limit» → `ntm quota` → `ntm rotate` до перехода к Mail recovery.
- **OperatingProcedure.md → Recovery section:** quota death — первая проверка `ntm quota`, потом `ntm rotate`, потом `--robot-health-restart-stuck`.
- **LoopPrompt.md:** в looper-проходе добавить раз в ~5 итераций (~15 мин) проверку `ntm quota --warn=80` — preemptive rotation до того, как все panes одновременно упадут в 429.

### Когда **не** использовать
- Если аккаунты не настроены через `caam` — `ntm rotate` некуда переключать.
- Если quota death затронул не провайдер агентов, а внешний API — rotate не поможет.

---

## Gap A4 — `ntm --robot-causality` (timeline для пост-морт)

### Симптом
Swarm развалился час назад. Чтобы понять причину, оператор читает scrollback каждого pane вручную и пытается восстановить порядок событий.

### Решение
`ntm --robot-causality` строит timeline нормализованных событий (mail, beads, dispatch, capture, conflicts) с фильтрами по pane / bead / chain / time-range.

### Команды

```bash
ntm --robot-causality --causality-since=1h
ntm --robot-causality --causality-bead=br-123
ntm --robot-causality --causality-pane=3 --causality-limit=50
ntm --robot-causality --causality-type=conflict --causality-since=30m
ntm --robot-causality --causality-chain=<correlation-id>
```
### Где встраивать в OrchestratorSwarm
- **RealityCheckDigest.md → каждые ~16 мин:** перед digest вызывать `ntm --robot-causality --causality-since=16m` чтобы зафиксировать что произошло между двумя reality-check-ами.
- **AgentMailRunbook.md → пост-инцидент:** после `am doctor repair` / `reconstruct` сразу делать causality по последнему часу чтобы понять blast radius.
- **OperatingProcedure.md → стalled bead investigation:** `--causality-bead=<id>` вместо чтения mail-thread + git-log + scrollback вручную.
- **Memory (PAI):** при recovery action — Edit PRD `## Decisions`; выдержка из `ntm --robot-causality` может стать evidence в PRD или `/ce-compound`.

### Когда **не** использовать
- В горячей фазе (минута назад) — `--robot-snapshot` + `tmux capture-pane` дают актуальнее.
- Когда нужен не таймлайн, а текущее состояние — это `--robot-snapshot`, не causality.

---

## Сводная карта: gap → файл OrchestratorSwarm

| Gap | NTM-команда | Куда добавить упоминание |
|---|---|---|
| A1 | `ntm pipeline run/status/resume` | `OperatingProcedure.md` (Quick Start, recovery), `LoopPrompt.md` |
| A2 | `ntm template`, `ntm session-templates`, `ntm recipes` | `RolePrompts.md`, `GoalDispatch.md`, `OperatingProcedure.md` |
| A3 | `ntm quota`, `ntm rotate`, `--robot-health-restart-stuck` | `AgentMailRunbook.md`, `OperatingProcedure.md`, `LoopPrompt.md` |
| A4 | `ntm --robot-causality` | `RealityCheckDigest.md`, `AgentMailRunbook.md`, `OperatingProcedure.md` |

## Anti-pattern: не делать всё сразу

Не пытайся внедрить все 4 gap-а одновременно. Порядок по ROI:

1. **A2 (templates/recipes)** — быстрый выигрыш, низкий риск, сразу экономит время на каждом dispatch.
2. **A4 (causality)** — добавить в RealityCheckDigest, нулевой риск (read-only).
3. **A3 (rotate/quota)** — добавить в Runbook, требует настроенного `caam`.
4. **A1 (pipeline)** — самое инвазивное, требует написать стабильный YAML, делать когда flow устаканен.
