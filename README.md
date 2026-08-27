# AI Coding Kit

一套小型、可移植的 AI coding agent 文件框架。它把跨工具共用的工作約定放在
`AGENTS.md`，以精簡的 `CLAUDE.md` bridge 讓 Claude Code 載入同一份內容，並將架構決策、
踩雷紀錄與待辦分析分流到按需讀取的文件。

A small, portable documentation framework for AI coding agents. It keeps the shared
working agreement in `AGENTS.md`, uses a minimal `CLAUDE.md` bridge so Claude Code loads
the same content, and routes architecture decisions, pitfalls, and task analysis to
on-demand documents.

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

1. Fill the placeholders in `AGENTS.md`, especially Behaviour Contracts.
2. Put architectural rationale in `ARCHITECTURE.md` and known traps in `ERRORS.md`.
3. Put personal settings in `CLAUDE.local.md`, or copy
   `.claude/settings.local.json.example` to `.claude/settings.local.json`.
4. Run `aikit-check`, then use `aikit-context` to verify what the agent actually loads.

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
AGENTS.md
CLAUDE.md
CLAUDE.local.md                  # gitignored
ARCHITECTURE.md
ERRORS.md
TASKS.md
.claude/
  hooks/
    prevent-default-branch-edits.sh
    post-edit.sh
  settings.json
  settings.local.json.example
```

`prevent-default-branch-edits.sh` 阻擋 agent 在 default branch 直接 Edit/Write；
`post-edit.sh` 在支援的 source file 被修改後執行可用的 formatter、lint 與 tests。

`prevent-default-branch-edits.sh` blocks agent Edit/Write operations on the default
branch. `post-edit.sh` runs available formatting, linting, and tests after supported
source files are changed.

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
- `aikit-check` 驗證可被機械判定的文件宣告，但不能判斷文字內容是否完整或正確。
- `aikit-context` 的載入規則是實測的 implementation detail；Claude Code 升級後請重新
  執行 `--isolated`。
- Hooks and settings use Claude Code's format; other agents can still consume
  `AGENTS.md` directly.
- `aikit-check` validates mechanically falsifiable claims, not prose completeness.
- Context-loading behavior is measured implementation detail; rerun `--isolated` after
  Claude Code upgrades.
