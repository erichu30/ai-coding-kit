# AI Coding Kit

一套小型、可移植的 AI coding agent 文件框架，支援 Claude Code、Codex 與
Antigravity CLI。它把跨工具共用的工作約定放在 `AGENTS.md`，以精簡的 bridge 與
workspace routing 讓三種工具遵循同一份內容，並將架構決策、踩雷紀錄與待辦分析分流到
按需讀取的文件。

A small, portable documentation framework for Claude Code, Codex, and Antigravity CLI.
It keeps the shared working agreement in `AGENTS.md`, uses minimal bridges and workspace
routing so all three tools follow the same source, and routes architecture decisions,
pitfalls, and task analysis to on-demand documents.

## 核心概念 / Core ideas

- 一份事實只維護在一個地方；不同 agent 共用 `AGENTS.md`。
- Always-loaded context 保持精簡，只放動手改 code 前必須知道的規則。
- 個人路徑、權限與機器設定放在 gitignored local files。
- 可機械驗證的文件宣告交給 `aikit-check`，不依賴人工記憶。
- Mechanical rules such as formatting, tests, and default-branch protection live in
  hooks; rationale stays in documentation.

設計理由與實測結果請見 [Principles](docs/PRINCIPLES.md) 與
[Claude Code context findings](docs/FINDINGS.md).

## 系統需求 / Requirements

- Bash 3.2+
- Git
- Python 3
- Claude Code CLI（只有 `aikit-context` 需要 / required only by `aikit-context`）
- Codex 或 Antigravity CLI（選用，依你實際使用的 agent / optional, according to
  the agents you use）

產生的 post-edit hook 會依專案語言選用已安裝的工具，例如 Go、Ruff/Pytest、
Prettier/ESLint 或 Cargo；沒有安裝的 optional tool 會被略過。

The generated post-edit hook uses installed language tools such as Go, Ruff/Pytest,
Prettier/ESLint, or Cargo. Missing optional tools are skipped.

## 安裝 / Installation

將 repo 的 `bin` 目錄加入 `PATH`：

Add this repository's `bin` directory to `PATH`:

```bash
git clone <repository-url> ~/src/ai-coding-kit
export PATH="$HOME/src/ai-coding-kit/bin:$PATH"
```

若要永久使用，將 `export` 加到 shell profile（例如 `~/.zshrc`）。在本 repo 尚未
push 前，也可以直接用絕對路徑執行 `bin/aikit-init`。

For persistent use, add the `export` line to your shell profile, such as `~/.zshrc`.
Before this repository is pushed, invoke `bin/aikit-init` by its absolute path.

## 快速開始 / Quick start

目標資料夾必須已是 Git repository。初始化工具不會覆寫任何既有檔案。

The target must already be a Git repository. The initializer never overwrites existing
files.

```bash
cd /path/to/your-project
git init                         # skip if already a repository
aikit-init --dry-run             # preview only
aikit-init                       # scaffold the current repository
```

也可以指定另一個 repo：

You can also target another repository:

```bash
aikit-init --dry-run /path/to/repository
aikit-init /path/to/repository
```

初始化後：

After initialization:

1. 填寫 `AGENTS.md` 的 placeholders，尤其是 Behaviour Contracts。
2. 將架構原因寫入 `ARCHITECTURE.md`、已踩過的坑寫入 `ERRORS.md`。
3. 將個人設定放入 `CLAUDE.local.md` 或複製
   `.claude/settings.local.json.example` 為 `.claude/settings.local.json`。
4. 執行 `aikit-check`，再用 `aikit-context` 驗證 agent 實際載入哪些文件。
5. 使用 Codex 時呼叫 `$ai-coding-workflow`；使用 Antigravity 時呼叫 `/develop`。

1. Fill the placeholders in `AGENTS.md`, especially Behaviour Contracts.
2. Put architectural rationale in `ARCHITECTURE.md` and known traps in `ERRORS.md`.
3. Put personal settings in `CLAUDE.local.md`, or copy
   `.claude/settings.local.json.example` to `.claude/settings.local.json`.
4. Run `aikit-check`, then use `aikit-context` to verify what the agent actually loads.
5. Invoke `$ai-coding-workflow` in Codex or `/develop` in Antigravity.

## 跨工具 workflow / Cross-agent workflow

三種 agent 共用相同的交付邊界：先理解與確認 scope，在 feature branch 上以 test-first
方式實作，執行 fresh verification，建立 local commit，然後停止等待人工 review。Push、
pull request 或 deployment 都需要另外明確授權。

All three agents share the same delivery boundary: understand and approve scope, work on
a feature branch with test-first implementation, run fresh verification, create a local
commit, and stop for human review. Pushing, opening a pull request, or deploying requires
separate explicit approval.

### 為什麼需要 bridge / Why bridges exist

各 agent 的原生入口不同，但 project facts 不應複製三份。本 kit 將 `AGENTS.md` 設為
single source of truth，再用最薄的 tool-specific file 導向它。

Each agent has a different native entry point, but project facts should not be copied
three times. This kit makes `AGENTS.md` the single source of truth and uses the thinnest
possible tool-specific file to route each agent to it.

```text
                         PROJECT INSTRUCTION ROUTING

  Claude Code                     Codex                    Antigravity
       │                             │                          │
       │ auto-load                   │ auto-load                │ workspace rule
       ▼                             │                          ▼
 ┌───────────┐                       │              ┌────────────────────────┐
 │ CLAUDE.md │                       │              │ .agents/rules/         │
 └─────┬─────┘                       │              │ working-agreement.md   │
       │ @AGENTS.md                  │              └───────────┬────────────┘
       │                             │                          │ read AGENTS.md
       └──────────────────────┬──────┴──────────────────────────┘
                              ▼
                       ┌─────────────┐
                       │  AGENTS.md  │  single source of truth
                       └──────┬──────┘
                              │ routes only when needed
             ┌────────────────┼────────────────┐
             ▼                ▼                ▼
      ARCHITECTURE.md      ERRORS.md        TASKS.md
      design rationale     known traps      planned work
```

### 工具能力比較 / Tool comparison

| Capability | Claude Code | Codex | Antigravity CLI | This kit |
|---|---|---|---|---|
| Native persistent project instructions | `CLAUDE.md` | `AGENTS.md` | `.agents/rules/` | Shared facts live in `AGENTS.md` |
| Route to shared instructions | `@AGENTS.md` import | Direct discovery | `working-agreement.md` rule | No duplicated project rules |
| Repo-scoped reusable procedure | Claude-specific skills/commands | `.agents/skills/*/SKILL.md` | `.agents/skills/*/SKILL.md` | Codex and Antigravity share one skill |
| Explicit workflow invocation | Normal request or Claude command | `$ai-coding-workflow` | `/develop` | Same delivery boundary |
| Tool-specific enforcement | `.claude/hooks/` | Agent instructions plus repo tooling | Permission/review settings | Hooks never pretend to be cross-tool |
| Personal machine configuration | `CLAUDE.local.md`, local settings | User-level Codex configuration | `~/.gemini/` configuration | Personal values remain gitignored |

> Claude Code does not use the shared `.agents/skills` path in this kit. Its persistent
> workflow boundary comes through `CLAUDE.md → AGENTS.md`, while mechanical enforcement
> comes from `.claude/hooks/`. Codex and Antigravity share the actual `SKILL.md`.

### Workflow 如何被觸發 / Workflow invocation

```text
 Claude Code
 ───────────
 normal coding request
        │
        ▼
 CLAUDE.md ──> AGENTS.md ──> project commands + contracts
        │
        └──────────────────> .claude/hooks enforce branch/edit checks


 Codex
 ─────
 $ai-coding-workflow
        │
        ▼
 .agents/skills/ai-coding-workflow/SKILL.md
        │
        └──────────────────> follows AGENTS.md + shared delivery workflow


 Antigravity CLI
 ───────────────
 /develop <request>
        │
        ▼
 .agents/workflows/develop.md
        │ routes to
        ▼
 .agents/skills/ai-coding-workflow/SKILL.md
        │
        └──────────────────> .agents/rules/working-agreement.md ──> AGENTS.md
```

### 共用交付流程 / Shared delivery lifecycle

```text
┌──────────────┐
│ User request │
└──────┬───────┘
       ▼
┌──────────────────────────┐
│ Read guidance + inspect  │
│ repo and existing changes│
└────────────┬─────────────┘
             ▼
      ┌─────────────┐       unclear / scope-changing
      │ Scope clear?├──────────────────────────────┐
      └──────┬──────┘                              │
             │ yes                                 ▼
             ▼                              ┌───────────────┐
┌──────────────────────────┐                │ Ask the human │
│ Present approach and get │◀───────────────┤ for direction │
│ approval when required   │                └───────────────┘
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│ Create focused branch    │
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│ RED: write failing test  │
│ and observe the failure  │
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│ GREEN: minimal change    │
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│ Fresh verification       │
│ tests + lint + full diff │
└────────────┬─────────────┘
             ▼
      ┌─────────────┐       no
      │ All green?  ├──────────────> diagnose / fix / verify again
      └──────┬──────┘
             │ yes
             ▼
┌──────────────────────────┐
│ Focused local commit     │
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│ STOP for human review    │
└────────────┬─────────────┘
             ▼ explicit approval only
┌──────────────────────────┐
│ Push / PR / deploy       │
└──────────────────────────┘
```

「完成 implementation」不等於「取得 publish 權限」。即使測試全部通過，agent 仍應在
local commit 後停止；push、PR 和 deployment 是各自獨立的 external mutation。

“Implementation complete” does not mean “authorized to publish.” Even with a green test
suite, the agent stops after the local commit; push, PR creation, and deployment are
separate external mutations.

Codex 官方文件說明 repo guidance 使用 `AGENTS.md`，repo skills 使用
`.agents/skills/`。Google 的 Antigravity 文件也指定 workspace skills 使用
`.agents/skills/`，並以 `.agents/rules/` 和 `.agents/workflows/` 提供 workspace
customization。

Official references: [Codex customization](https://learn.chatgpt.com/docs/customization/overview)
and [Antigravity workspace customization](https://codelabs.developers.google.com/getting-started-agy-ide#8).

## 指令 / Commands

### `aikit-init [--dry-run] [repository]`

將 templates、Claude Code hooks 與 settings 複製到目標 repo。既有檔案會顯示為
`skip`；`CLAUDE.local.md` 和 `.claude/settings.local.json` 會加入 `.gitignore`。

Copies templates, Claude Code hooks, and settings into the target repository. Existing
files are reported as `skip`; local-only files are added to `.gitignore`.

### `aikit-check [repository]`

檢查 `CLAUDE.md` 是否匯入 `AGENTS.md`、shared docs 是否含個人 home paths、local
Markdown links、文件提及的 source files/symbols，以及 local file 是否被誤追蹤。

Checks context wiring, personal home paths in shared docs, local Markdown links,
referenced source files/symbols, and accidental tracking of local-only files.

```bash
aikit-check
aikit-check /path/to/repository
```

### `aikit-context [repository]`

暫時加入隨機 canary token，停用 Claude Code 的讀檔工具後詢問該 token，再還原文件，
用來確認文件是由 context 自動載入，而不是 agent 自己搜尋到。

Temporarily adds a random canary token, asks Claude Code for it with file-reading tools
disabled, and restores the document. This distinguishes automatic context loading from
agent-driven file discovery.

```bash
aikit-context
aikit-context /path/to/repository
aikit-context --isolated          # clean-room test of Claude Code loading rules
```

`aikit-context` 會呼叫 Claude Code，可能產生 API 使用量，單次 probe 最長等待 180 秒。

`aikit-context` invokes Claude Code, may consume API usage, and limits each probe to 180
seconds.

## 產生的結構 / Generated layout

```text
repository/
├── AGENTS.md                         # shared project working agreement
├── CLAUDE.md                         # Claude bridge: @AGENTS.md
├── CLAUDE.local.md                   # personal, gitignored
├── ARCHITECTURE.md                   # why the system is shaped this way
├── ERRORS.md                         # traps worth remembering
├── TASKS.md                          # analysed but unimplemented work
├── .claude/
│   ├── hooks/
│   │   ├── prevent-default-branch-edits.sh
│   │   └── post-edit.sh
│   ├── settings.json                 # shared Claude hook wiring
│   └── settings.local.json.example   # personal config example
└── .agents/
    ├── rules/
    │   └── working-agreement.md      # Antigravity → AGENTS.md
    ├── skills/
    │   └── ai-coding-workflow/
    │       └── SKILL.md              # Codex + Antigravity workflow
    └── workflows/
        └── develop.md                # Antigravity /develop command
```

`prevent-default-branch-edits.sh` 阻擋 agent 在 default branch 直接 Edit/Write；
`post-edit.sh` 在支援的 source file 被修改後執行可用的 formatter、lint 與 tests。

`prevent-default-branch-edits.sh` blocks agent Edit/Write operations on the default
branch. `post-edit.sh` runs available formatting, linting, and tests after supported
source files are changed.

## 文件應該放哪裡？ / Where should guidance live?

先依「是否每次都必須知道」分類，再依用途選擇檔案。不要因為三個 agent 有三種入口就
複製三份相同內容。

Classify guidance by whether every task needs it, then choose a destination by purpose.
Do not copy the same rule three times merely because the agents have different entry
points.

```text
New guidance or knowledge
│
├─ Must every agent know it before touching code?
│  └─ yes ──> AGENTS.md
│             examples: commands, invariants, conventions, routing table
│
├─ Is it a repeatable multi-step procedure?
│  └─ yes ──> .agents/skills/<name>/SKILL.md
│             Codex: $name     Antigravity: skill discovery
│
├─ Should it be an Antigravity slash command?
│  └─ yes ──> .agents/workflows/<command>.md
│             keep it thin; route to a shared skill
│
├─ Does it explain why the architecture exists?
│  └─ yes ──> ARCHITECTURE.md
│
├─ Is it a non-obvious trap already encountered?
│  └─ yes ──> ERRORS.md
│
├─ Is it planned work with analysed options?
│  └─ yes ──> TASKS.md
│
└─ Is it personal, secret, or machine-specific?
   └─ yes ──> CLAUDE.local.md or local settings (gitignored)
```

### One fact, one place

```text
GOOD                                      BAD
────                                      ───
AGENTS.md                                 AGENTS.md
  └─ canonical invariant                   └─ invariant copy A

CLAUDE.md                                 CLAUDE.md
  └─ @AGENTS.md bridge                     └─ invariant copy B

.agents/rules/working-agreement.md        GEMINI.md / workspace rule
  └─ route to AGENTS.md                    └─ invariant copy C

Result: one update                       Result: silent drift
```

Bridge files state where canonical guidance lives. They should not become alternative
copies of that guidance.

## 開發與驗證 / Development and verification

```bash
bash -n bin/* hooks/*.sh tests/*.sh
tests/test-kit.sh
```

`aikit-context --isolated` 是較慢、且需要有效 Claude Code session 的 integration
probe，不包含在快速測試中。

`aikit-context --isolated` is a slower integration probe requiring a valid Claude Code
session, so it is not part of the fast test suite.

## 限制 / Limitations

- Hooks 與 settings 使用 Claude Code 的格式；其他 agent 仍可直接使用 `AGENTS.md`。
- Antigravity 的 `/develop` 是 workspace workflow；Codex 應使用
  `$ai-coding-workflow` 呼叫同一個 skill。
- `aikit-check` 驗證可被機械判定的文件宣告，但不能判斷文字內容是否完整或正確。
- `aikit-context` 的載入規則是實測的 implementation detail；Claude Code 升級後請重新
  執行 `--isolated`。
- Hooks and settings use Claude Code's format; other agents can still consume
  `AGENTS.md` directly.
- `/develop` is an Antigravity workspace workflow; Codex invokes the same underlying
  skill as `$ai-coding-workflow`.
- `aikit-check` validates mechanically falsifiable claims, not prose completeness.
- Context-loading behavior is measured implementation detail; rerun `--isolated` after
  Claude Code upgrades.
