# Loop Prompt

Use this as the short repeating prompt for a looper pane or as an orchestrator reminder.

## Autonomous looper bootstrap (mandatory after dispatch)

**Когда:** сразу после того как orchestrator отправил role prompts на **все** worker/reviewer/QA panes (последний dispatch в батче; при bootstrap swarm — сразу после первичного fleet dispatch).

**Что сделать на orchestrator pane (cc/gmi — slash):** одна литеральная строка + Enter. **Не спрашивай пользователя** «запустить loop?» / «продолжить looper?».

```text
/loop 3m /OrchestratorSwarm continue swarm execution — Algorithm EXECUTE tick (read LoopAlgorithmAnchor.md first)
```
**Поведение:**

- Claude Code **сам** пингует orchestrator pane каждые **~3 минуты** — человек не нужен между тиками.
- Каждый ping = один **Cycle** ниже (шаги 1–20 из блока «Cycle body»).
- **Reality-check digest** для человека — встроено в Cycle (не чаще ~16 мин wall-clock); см. первый абзац Cycle body.
- Если `/loop` **уже** активен в этой сессии — **не** запускай второй; продолжай существующий cadence.
- Остановка loop: (a) saturation → LEARN (`LoopAlgorithmAnchor.md`); (b) пользователь «стоп»; (c) **AFK exit** — `afk_stall_loops >= 6` или невосстановимый блокер → **`AFKExitHandoff.md`** (стоп + `docs/swarm-afk-exit-handoff.md`). В AFK **не** крути loop бесконечно без прогресса.

**Запрещено:** оставлять swarm «раздиспатченным» без `/loop`; ждать подтверждения перед `/loop 3m …`.

---

## Cycle body (повторяется каждые ~3 min автоматически)

Текст ниже — то, что orchestrator выполняет **на каждом** тике `/loop` (и при ручном «Run the OrchestratorSwarm loop» без built-in loop).

```text
/OrchestratorSwarm continue swarm execution — Algorithm EXECUTE tick

Ты looper для текущего NTM swarm внутри **EXECUTE-фазы одного PRD** (Algorithm). Каждые ~3 минуты выполняй шаги 0–20.

**Шаг 0 — Algorithm anchor (ОБЯЗАТЕЛЕН, каждый тик):** открой **`LoopAlgorithmAnchor.md`** (рядом с этим файлом) и пройди чеклист **«Этот тик (~3 min)»**. Знай путь к активному PRD (`MEMORY/WORK/<slug>/PRD.md`), `phase: execute`, `progress: M/N`. Не начинай pane/beads координацию, пока не сверил PRD frontmatter. На digest-тике (~16 min) — также чеклист **«digest-тик»** из того же файла + sub-VERIFY в PRD `## Verification` (`AlgorithmIntegration.md`). При saturation — чеклист **LEARN** и остановка `/loop`.

**Reality-check для человека (не каждый тик):** не чаще **чем раз в ~16 минут** с предыдущей сводки (**wall-clock**). Если считаешь только номер цикла при типичных ~3 мин между проходами — обычно это **каждый 6-й** полный проход после прошлой digest (≈18 мин); при наличии времени выдай digest на **первом** цикле, где прошло **≥16 мин**. **Дополнительно** к шагам 1–20 выведи честную сводку по шаблону **`RealityCheckDigest.md`**: стадии **vs исходный план** (README/plan/эпики), что на `main`, ASCII-прогресс, таблица panes×beads, velocity vs бюджет плана, блокеры, риски, bottom line (качество/темп/главный риск). В остальных тиках этот формат не разворачивай — координация без «простыни».

1. **Rules refresh (ОБЯЗАТЕЛЕН):** открой **`RulesRefresh.md`** и выполни refresh для **этого** тика: **проект** `<repo>/AGENTS.md` + `<repo>/CLAUDE.md` (Read, не stat). На **каждом ~3-м тике** и **digest-тике** — также **глобальные** `$GLOBAL_AGENTS.md` (see `docs/ECOSYSTEM.md`) + `~/.claude/CLAUDE.md`. Затем освежи `/OrchestratorSwarm`: SKILL.md; при сомнениях OperatingProcedure.md, AlgorithmIntegration.md, SkillRouting.md, RolePrompts.md, Gotchas.md.
1а. **Память orchestrator (PAI + CM + CASS) — раз в ~2-3 looper-цикла, и обязательно перед сложным dispatch / role failover / Agent Mail recovery / reality-check digest:** `cm context "orchestrate swarm <repo> <blocker>" --json`. При incident — `/context-search "<симптом>"` или `cass search "…" --json`. После **recovery action** — Edit PRD `## Decisions` (что случилось + fix, без секретов); при системном уроке — `/ce-compound`. На reality-check digest — Edit PRD `## Verification` + Algorithm-style Q1–Q3 в digest (формальный LEARN — в конце swarm). См. **`MemoryIntegration.md`**.
2. Проверь **все** pane по списку (не только «активные»): живы ли, чем заняты, ждут ли ввода, есть ли stuck > 1 цикла. **Не доверяй только NTM Activity / robot-snapshot** — сверяй **`tmux capture-pane`** (~10–20 последних строк) на каждом swarm-pane: Activity иногда **`WAITING`**, хотя агент уже Thinking/_tools; или наоборот — в input висит отправленный текст без submit. **`Sent to pane` ≠ промпт выполняется.** **Инвентарь простоя:** если worker/reviewer/QA у **пустого prompt** без Thinking/Compacting и по твоей карте **нет** текущего задания (in_progress / явный marching-order в Mail) — это **дефект оркестрации**: немедленно dispatch (Mail предпочтительно при риске ввода) или wake-up `bv`+assign; не оставляй «остальных в покое», потому что один pane уже занят. **Застрявший текст в input** (обрезанный paste, "[Pasted", незакрытый блок) — `/clear` и заново отправь приказ через Mail. Дополнительно лови **«панель мёртвая по capacity/auth»**: в выводе pane — quota/rate limit exhausted, 401/invalid key, повторяющиеся provider errors, зависший login; или **нет ответа и нет прогресса** 1–2 looper-цикла там, где должен был быть ход (не путай с закономерным Thinking — capture подтвердит).
3. **Failover ролей при мёртвой панели:** если worker/reviewer/QA **не может продолжать роль** (лимиты, ключ, сломанный CLI, полный stop) — **не оставляй слот пустым**. Возьми **донора**: в приоритете **idle** или **только что закрыл bead** и готов к следующему; в дефиците панелей — наименее критичный worker с явным объяснением в Agent Mail (временно снимаем реализацию, поднимаем review/QA). Сначала **явное переназначение роли** (коротко: «теперь ты Reviewer N / QA»), затем **полный role prompt** с буквальными `/skill`/`$skill` как в штатном dispatch; обнови pane map; **одно сообщение в Mail** всем затронутым агентам (кто кем стал, какие BD/резервации). Мёртвый pane: исключи из dispatch до починки; после смены ключа — restart и `macro_start_session`, см. AgentMailRunbook. См. OperatingProcedure → Pane capacity and role failover.
4. Проверь Agent Mail health: curl http://127.0.0.1:8765/health (или эквивалент); при сомнениях am doctor check --verbose; inbox, stale locks, ack_required.
5. **Пересечения по файлам (~каждые 3 мин):** проверь, нет ли конфликтующих или пересекающихся **file reservations** между panes на одном проекте — например `am robot reservations --conflicts` (или MCP/Agent Mail: активные reservations по `project_key`). Если два агента держат overlapping globs на одни и те же пути — это не «подождёт само»: кратко разрули через Agent Mail (кто отпускает резервацию / меняет bead), не доводи до мерж-конфликта в git. Сверь при сомнении с тем, кто какой BD-ID ведёт.
6. Если сервер Agent Mail только что подняли, был рестарт PID/MCP или socket errors — сверь число panes (по ролям) с зарегистрированными агентами проекта; «потерянным» panes — короткий ntm: немедленно /agent-mail macro_start_session для human_key репозитория. Лестница восстановления: AgentMailRunbook.md.
7. Убедись, что каждый pane регулярно проверяет Agent Mail и активно использует reservations/mail для blockers, overlap и handoff, но не спамит: только actionable сообщения, влияющие на routing, ownership, blockers, conflicts, review/QA findings или handoff.
8. Проверь beads: bv --robot-triage --format toon, bv --robot-next, stalled in_progress.
8б. **Stale bead detection (~каждые 12 минут):** Проверь все beads со статусом `in_progress`: не было ли активности более ~20 минут. Признаки stale: bead в `in_progress` но pane который его держал — либо мёртв, либо ушёл в Thinking без прогресса, либо pane переключился на другой bead но не освободил текущий. Команда: `br list --status in_progress` и сверь last_updated времени. Также проверь `am robot reservations --by-agent` — кто какие файлы держит по этому bead. Если stale найден:
  - Попробуй唤醒 мёртвый pane: `/clear` + сообщение в Mail ("твой bead <BD-ID> завис, проверь или отпусти").
  - Если pane не отвечает 1 цикл или clearly abandoned — верни bead в `open`: `br update <BD-ID> --status open`.
  - Проверь есть ли частично сделанные изменения в файлах bead (погляди git status / git diff).
  - Переназначь bead другому подходящему worker-у с полным dispatch (ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ + /goal если комплексный).
  - Предупреждение в Mail: "bead <BD-ID> переназначен с WX на WY, старый worker освобождён".
  - Если bead был в `in_progress` более 30 минут без progress и нет явного блокера — это candidate на force-reassign.
9. Проверь role separation: worker prompts -> только worker panes, reviewer prompts -> только reviewer panes, QA prompts -> только QA panes. Reassign явно перед сменой роли. В **каждом** marching order для worker/reviewer/QA включай строку про **self-loop** и файл (`WorkerLoopPrompt.md` ~6 мин для worker; `ReviewerLoopPrompt.md` / `QALoopPrompt.md` ~6 мин) + напоминание **`/` vs `$`** по типу pane.
10. Workers **никогда не «заканчивают и стоят»**: после close/commit обязаны Mail + следующий bead (см. `RolePrompts.md`). Ты **каждый цикл** сверяешь: у **каждого** worker либо in_progress BD, либо доказанный «нет ready» после bv+Mail — иначе dispatch. Workers не останавливаются после закрытия bead: они сразу берут следующий ready/open bead. Для каждого нового bead заново подбери skill bundle: SkillRouting.md + `ms suggest --cwd <repo>` + `ms search "<topic>" --robot`, bash `cm context "<bead>" --json`, `rg "<topic>" docs/solutions/`. Новый dispatch — блок ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ с `/cass-memory` сразу после `/agent-mail`. Fleet parity: обнови **всех** panes одного класса.
11. Если exact skill не найден, выбери ближайший по смыслу из SkillRouting.md/general workflows, не выдумывай имя скилла и не блокируй swarm. Перед выбором fallback'а — попробуй `ms suggest --cwd <repo>` и `ms search "<topic>" --robot` (это **локальный** поиск установленных скиллов; **не путать** с `/find-skills`, которая ставит внешние скиллы из реестра).
12. Баги направляй через ce-debug/diagnose, затем ubs или multi-pass-bug-hunting. Registration/auth/onboarding/chat flows требуют e2e-testing-for-webapps.
13. Перед длинным ntm send (полный role prompt с literal `/skill` строками): проверь pane idle — **обязательно `tmux capture-pane`** (~10–20 строк); robot-snapshot/Activity — только дополнение, не единственный источник. Если Thinking/Compacting/tool-running или paste в полёте — не вставляй простыню в input: отложи цикл или отправь тот же текст через Agent Mail send_message в inbox агента (см. OperatingProcedure.md → NTM Send, Busy Panes, **NTM Activity vs tmux capture-pane**). Короткие ntm: /clear, однострочный nudge — ок.
14. После осознанного ntm send (когда idle) всегда отправляй Enter в pane; на **следующем** проходе (или через один цикл) **capture-pane** подтверди, что нет «висящего» промпта в строке ввода и начался новый вывод модели.
15. Если pane завис: /clear, следующий цикл без реакции -> restart pane, bead вернуть в open.
16. Не запускай параллельные сборки одного проекта. Перед чисткой ресурсов: df -h && free -h.
17. Закрытые beads идут reviewers через ce-review; findings оформляй новыми beads, старые не переоткрывай.
17а. **PRD sync (Algorithm EXECUTE-фаза):** для каждого bead, закрытого с прошлого looper-цикла, проверь — покрывает ли он какой-то ISC текущего PRD (`MEMORY/WORK/<slug>/PRD.md`). Если да — Edit PRD: `- [ ] ISC-X` → `- [x] ISC-X`, обнови `progress: M/N` в frontmatter, `updated: <ISO ts>`. Если bead покрывает только часть составного ISC (несколько beads → один ISC) — не отмечай, ждём все. Если bead не относится ни к одному ISC — ничего не меняй. Подробности — `AlgorithmIntegration.md` → **Mapping: bead close → ISC update**. Это не «дополнительно» — это **обязательная часть EXECUTE-фазы**; без этого PRD устаревает и reality-check digest становится ложью.
17б. **Deep recap-read закрытых beads (анти-«closed without evidence», ОБЯЗАТЕЛЕН перед mark'ом ISC):** для каждого bead, закрытого с прошлого looper-цикла, прежде чем сделать шаг 17а — **прочитай что pane реально написал**:
    - `tmux capture-pane -p -t <session>:<pane> -S -30` — забери **recap-блок** (NATIVE/MINIMAL mode: `🗣️ agent recap` summary + `🔧 CHANGE` + `✅ VERIFY`).
    - `br show <id> --json | jq -r '.[0].close_reason // .[0].notes // "n/a"'` — что pane записал в close reason.
    - Если 🗣️ agent recap упоминает конкретный артефакт (file path, SHA, commit, NDJSON, repo, off-host push) — **проверь его** (`test -f <path>`, `jq -e . <ndjson>`, `git log origin/main..HEAD`, `git ls-remote`).
    - **Red flags** в recap/close reason — углубляйся вместо `[x]`: `absent`, `MISSING`, `SKIP`, `ECONNREFUSED`, `fallback`, `TODO`, `n/a`, generic "done/fixed/implemented" без ссылок, подозрительно быстрое закрытие (<2 мин от claim до close).
    - Если recap unclear или claim не подтверждается артефактом — **не mark'ай ISC, не пиши victory**: открой follow-up defect (`br create`) или эскалируй user'у одной короткой honest заметкой. Лучше отловить здесь, чем породить новый R1 review-defect.
    - Полный протокол (medium → deep), red-flag токены, примеры — `PaneRecapReading.md`.
18. Не отправляй role prompts самому себе: исключи orchestrator pane из всех ntm send target lists.
19. Никогда не создавай и не предлагай worktree. Все работают в текущем checkout на main.
20. **AFK gate (если оператор AFK / LaunchAFK):** обнови `afk_stall_loops` в PRD `## Decisions`. Нет прогресса за тик → +1. Если `>= 6` или немедленный триггер из **`AFKExitHandoff.md`** — **стоп**: `/loop stop`, Mail «AFK PAUSE», запиши **`docs/swarm-afk-exit-handoff.md`**, **не** начинай следующий тик. В AFK **не** спрашивай пользователя.
21. Иначе продолжай, пока есть open/stalled beads или review создаёт новые bugs. **Когда saturation достигнут** — LEARN по `AlgorithmIntegration.md` (verify → learn → reflections → complete). См. **`MemoryIntegration.md`**.
```
## Operator Checklist

- **After every fleet dispatch:** start `/loop 3m /OrchestratorSwarm continue swarm execution — Algorithm EXECUTE tick (read LoopAlgorithmAnchor.md first)` on the orchestrator pane if not already running — **never ask the user first**.
- Each Cycle (~3 min): **step 0** `LoopAlgorithmAnchor.md` → steps 1–20.
- **Algorithm:** every tick — PRD frontmatter + bead→ISC sync (step 17a); every ~16 min — sub-VERIFY in `## Verification`; on saturation — LEARN once, then stop `/loop`.
- **AFK:** every tick step 20 — `afk_stall_loops`; at >= 6 or hard blocker → **`AFKExitHandoff.md`** (no infinite loop).
- **Rules refresh:** каждый Cycle — **`RulesRefresh.md`** (project AGENTS+CLAUDE; global каждый ~3-й tick + digest). Не drift от repo/global policy.
- Re-read `/OrchestratorSwarm` SKILL.md at loop start so the orchestrator does not drift from its own constraints.
- **Memory pulse:** raz в ~2-3 цикла — `cm context "…" --json`; перед recovery — `/context-search` или `cass search`; после recovery — Edit PRD `## Decisions`. На digest — PRD `## Verification`. См. **`MemoryIntegration.md`**.
- **Local skill discovery:** для нового bead или незнакомой подсистемы — `ms suggest --cwd <repo>` и `ms search "<topic>" --robot` (локальные установленные скиллы; не `/find-skills` — та для внешних). Вкладывай этот шаг в **каждый** marching order для воркеров/ревьюверов/QA.
- Prefer robot/non-interactive commands.
- Every ~3 minutes, explicitly check **file reservation overlaps / conflicts** for the active project (`am robot reservations --conflicts` or equivalent); resolve via Agent Mail before git merge pain.
- Each loop, watch for **capacity/auth death** (quota, rate limits, bad keys, pane silence with no progress); **fail over roles** via explicit reassignment + Agent Mail — prefer idle or just-finished workers as donors; never leave reviewer/QA slots empty if the pipeline would stall.
- **Every ~12 minutes**: run **stale bead detection** — `br list --status in_progress` + `tmux capture-pane` on pane holding each in_progress bead. If a bead has no activity >~20 min or its holder pane is dead/stuck on wrong task → force-reassign: `br update <BD-ID> --status open` + dispatch to another worker with full prompt. Report reassignment in Agent Mail.
- Enforce high-signal coordination: no redundant status chatter, vague FYIs, or conversational threads in Agent Mail.
- After any Agent Mail restart or MCP blip, verify pane registration parity and re-bootstrap orphan panes per `AgentMailRunbook.md`.
- If an agent needs a new task, send a complete role prompt with **ОБЯЗАТЕЛЬНЫЕ ПЕРВЫЕ ВЫЗОВЫ** (literal `/skill` or `$skill` lines), not a prose skill list. **Roll out** that style to every swarm pane on the same role class — partial updates explain “one pane 3 calls, nine panes 0”.
- Every dispatch must include the **self-loop** line for that role (worker `WorkerLoopPrompt.md` ~6 min; reviewer `ReviewerLoopPrompt.md`; QA `QALoopPrompt.md` ~6 min; **`/` vs `$`** per pane type).
- If exact skill lookup fails, choose the closest meaningful fallback and continue.
- After changing prompt style to literal first-invocation lines for any pane, **extend the same style** to all other swarm panes on the next dispatch batch.
- Verify role separation before dispatch: do not mix worker, reviewer, and QA pane targets.
- Exclude the orchestrator pane from dispatch targets; never `ntm send` role prompts to yourself.
- Every `ntm send` that pastes a **large** prompt must be **idle-gated** first, or use **Agent Mail** instead; short control messages may still use `ntm send` + Enter.
- Each loop, **enumerate every worker/reviewer/QA pane**; empty prompt + no assignment = **dispatch or clear-input + resend** this cycle — not "I'll be cautious and skip."
- **tmux capture-pane** on doubtful panes each loop — do not classify liveness from NTM Activity alone (`WAITING` can lie).
- About every **16 minutes** since the last digest (wall-clock), or roughly every **6th** loop at ~3 min spacing; emit the **reality-check digest** (`RealityCheckDigest.md`): plan vs main, pane table, velocity, blockers, risks — not bead-count-only status.
