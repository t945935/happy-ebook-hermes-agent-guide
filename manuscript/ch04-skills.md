# 第 4 章：Skills 的建立與使用

> **本章目標**  
> 讓讀者能安裝、呼叫、檢查並建立一個可重複使用的 Skill。完成後讀者能建立一個 Skill，呼叫它完成一項工作，並用 `hermes skills check` 檢查。

> **適用讀者與前提**  
> - 已完成第 1～3 章，Hermes 基本聊天正常運作  
> - 理解 slash command、`~/.hermes/` 目錄結構  
> - 具備基本 Markdown 與 YAML 語法概念

---

## 4.1 核心概念

### 4.1.1 Skill 是什麼

Skill 是**可重複使用的任務模組**，封裝了：
- **觸發條件**：何時應被呼叫（關鍵字、toolset、平台）
- **執行步驟**：標準化流程、工具呼叫順序、參數模板
- **參考資料**：`references/` 下的 API 文件、範例、cheatsheet（按需載入）
- **安全邊界**：platform 限制、toolset 需求、審計追蹤

> **Progressive Disclosure**（漸進式揭露）  
> - `skills_list()`：session 啟動時載入所有 skill 摘要（~3k tokens）  
> - `skill_view(name)`：agent 決定需要時才載入完整 SKILL.md  
> - `skill_view(name, file_path)`：只載入特定 reference 檔案

### 4.1.2 Skill 來源分級

| 來源 | 信任等級 | 安裝方式 | 掃描 |
|------|----------|----------|------|
| **Bundled** | `builtin` | 隨 Hermes 安裝複製到 `~/.hermes/skills/` | 無（內建信任） |
| **Official optional** | `official` | `hermes skills install official/...` | 掃描但不阻擋 |
| **Trusted registries** | `trusted` | `hermes skills install openai/skills/...` 等 | 掃描、caution 可 `--force` |
| **Community / URL / GitHub** | `community` | `hermes skills install <url>` 或 `owner/repo` | **危險 verdict 永久阻擋**，caution 需 `--force` |

---

## 4.2 實作情境

| 情境 | 指令 |
|------|------|
| 瀏覽官方可選 skills | `hermes skills browse --source official` |
| 搜尋特定主題 | `hermes skills search kubernetes` |
| 預覽再決定 | `hermes skills inspect openai/skills/k8s` |
| 從 Hub 安裝 | `hermes skills install official/security/1password` |
| 從 URL 直接安裝單檔 SKILL.md | `hermes skills install https://sharethis.chat/SKILL.md` |
| 從 GitHub repo 安裝 | `hermes skills install owner/repo --enable` |
| 列出已安裝 hub skills | `hermes skills list --source hub` |
| 檢查上游更新 | `hermes skills check` |
| 更新有變更的 skills | `hermes skills update` |
| 移除 skill | `hermes skills uninstall k8s` |
| 還原 bundled skill | `hermes skills reset google-workspace --restore` |
| 在 chat 中呼叫 | `/ascii-art Make a banner` |
| 在 chat 中瀏覽/安裝 | `/skills browse`、`/skills install ...` |
| 從素材自動生成 skill | `/learn <topic>` |

---

## 4.3 步驟與指令

### 4.3.1 瀏覽與搜尋 Skills Hub

```bash
# 瀏覽所有來源（官方優先）
hermes skills browse

# 僅瀏覽官方可選 skills
hermes skills browse --source official

# 搜尋關鍵字（所有來源）
hermes skills search kubernetes

# 限定來源搜尋
hermes skills search react --source skills-sh
hermes skills search https://mintlify.com/docs --source well-known

# 輸出 JSON 供腳本處理
hermes skills search kubernetes --json
```

**預期結果（示意）**：
```text
SOURCE          IDENTIFIER                           DESCRIPTION
official        official/security/1password          Manage 1Password vaults
official        official/research/arxiv              Search and fetch arXiv papers
skills-sh       skills-sh/vercel-labs/json-render    Render JSON as React components
github          openai/skills/skill-creator          Create new skills from scratch
```

---

### 4.3.2 安裝 Skill

```bash
# 官方可選 skill（自動走 security scan）
hermes skills install official/research/arxiv

# 從 Hub 直接安裝（在 chat 中）
/skills install official/creative/songwriting-and-ai-music

# 從 HTTP(S) URL 安裝 SKILL.md + 參考檔
hermes skills install https://sharethis.chat/SKILL.md
# 指定名稱（當 SKILL.md 無 name frontmatter 時）
hermes skills install https://example.com/SKILL.md --name my-skill

# 從 GitHub repo 安裝（標記為 custom/unreviewed）
hermes skills install openai/skills/k8s --enable

# 強制安裝被 scanner 擋下的 skill（需人工審閱）
hermes skills install suspicious/skill --force
```

**安裝過程**：
1. 下載並解壓至暫存區
2. **Security scan**：data exfiltration、prompt injection、destructive commands、supply-chain signals
3. 複製至 `~/.hermes/skills/<category>/<skill-name>/`
4. 記錄 provenance 至 `skills/.hub/lock.json`（source URL、content hash、scanner version、findings、timestamp）
5. 重新整理 `skills_list()` 快取

**驗證**：
```bash
hermes skills list | grep arxiv
# 或在 chat：
/skills search arxiv
```

---

### 4.3.3 在 Chat 中呼叫 Skill

每個安裝的 skill 自動成為 **slash command**：

```text
# 直接給任務
/ascii-art Make a banner that says "HELLO WORLD"
/plan Design a REST API for a todo app
/github-pr-workflow Create a PR for the auth refactor

# 僅輸入 skill 名稱，讓 agent 詢問細節
/excalidraw
/research-arxiv
```

**自然語言觸發**：直接告訴 Hermes "用 research-arxiv skill 幫我找關於 transformers 的論文"，agent 會透過 `skill_view` 工具載入並執行。

---

### 4.3.4 建立自訂 Skill

#### 目錄結構
```
~/.hermes/skills/
└── my-category/
    └── my-skill/
        ├── SKILL.md              # 必要：主指令文件
        ├── references/           # 選擇性：按需載入
        │   ├── api-docs.md
        │   └── examples.md
        ├── templates/            # 選擇性：範本檔
        │   └── config.yaml
        └── scripts/              # 選擇性：可執行腳本
            └── setup.sh
```

#### SKILL.md 完整格式

```markdown
---
name: my-skill
description: Brief description of what this skill does (≤60 chars)
version: 1.0.0
author: Your Name
license: MIT
platforms: [macos, linux]        # 可選：限定 OS，省略則全平台
metadata:
  hermes:
    tags: [python, automation]
    category: devops
    fallback_for_toolsets: [web]      # 可選：當 web toolset 啟用時隱藏
    requires_toolsets: [terminal]     # 可選：需 terminal toolset 才顯示
    config:                           # 可選：需寫入 config.yaml 的設定
      - key: my.setting
        description: "What this controls"
        default: "value"
        prompt: "Prompt for setup"
# blueprint:                        # 可選：標記為可排程自動化
#   schedule: "0 9 * * *"
#   deliver: origin
#   prompt: "Task instruction for each run"
#   no_agent: false
required_environment_variables:     # 可選：skill 需要的 env vars
  - name: MY_API_KEY
    prompt: "Enter your API key"
    help: "Get one at https://example.com"
    required_for: "API access"
---

# My Skill Title

## Trigger Conditions
Use this skill when the user asks about [specific topic] or needs to [specific task].

## Procedure
1. First, check if [prerequisite] is available
2. Run `command --with-flags`
3. Parse the output and present results

## Pitfalls
- Common failure: [description]. Fix: [solution]
- Watch out for [edge case]

Run `check-command` to confirm the result is correct.

## References
For API details, load the reference: `skill_view("my-skill", "references/api-docs.md")`
```

> **關鍵規範**（官方作者標準）：
> - `description` ≤ 60 字元
> - 區段順序：Trigger Conditions → Procedure → Pitfalls → References
> - 使用 Hermes 內建工具（`read_file`、`write_file`、`run_command` 等），**不可**編造指令
> - `references/` 檔案需在 SKILL.md 內以 `skill_view(...)` 明確引用才會被載入

#### 實作範例：建立一個 "git-summary" Skill

```bash
mkdir -p ~/.hermes/skills/productivity/git-summary/references
```

`~/.hermes/skills/productivity/git-summary/SKILL.md`：
```markdown
---
name: git-summary
description: Generate a concise summary of recent git commits
version: 1.0.0
metadata:
  hermes:
    tags: [git, productivity]
    category: devops
    requires_toolsets: [terminal]
---

# Git Summary Skill

## Trigger Conditions
Use when user asks for recent commit summary, changelog, or "what changed".

## Procedure
1. Run `git log --oneline -20` to get recent commits
2. Group by author/type if needed
3. Present as formatted markdown

## Pitfalls
- Not in a git repo: Fix: check `git rev-parse --is-inside-work-tree` first
- Too many commits: Fix: limit with `-n` or date range

Run `git log --oneline -5` to confirm output format.
```

**驗證**：
```bash
hermes skills list | grep git-summary
# 在 chat：
/git-summary
# 應顯示最近 20 筆 commit 摘要
```

---

### 4.3.5 使用 `/learn` 從素材自動生成 Skill

```text
# 在 chat session 中
/learn "如何用 Python 的 requests 庫呼叫 REST API，包含 auth、retry、error handling"
/learn ~/docs/api-spec.md
/learn https://docs.example.com/api-reference
```

**行為**：
- agent 以現有工具（web search、file read 等）蒐集素材
- 依 house authoring standards 產出 `SKILL.md` + `references/` 分章節檔案
- 以 `skill_manage` tool 寫入 `~/.hermes/skills/`（**受 write-approval gate 保護**）
- 同主題再次 `/learn` 會**合併更新**既有 skill，不建立重複

**適用介面**：CLI、TUI、Dashboard、Gateway 同樣可用；Dashboard 有 "Learn a skill" 按鈕。

---

### 4.3.6 檢查與更新 Hub Skills

```bash
# 檢查所有已安裝 hub skills 是否有上游更新
hermes skills check

# 檢查特定 skill
hermes skills check react

# 更新所有有變更的 skills
hermes skills update

# 更新特定 skill（覆寫本地編輯需 --force）
hermes skills update react --force
```

**機制**：比對 `skills/.hub/lock.json` 記錄的 content hash 與上游最新 bundle。

---

### 4.3.7 Security Audit 與移除

```bash
# 重新掃描所有 hub skills
hermes skills audit

# 移除 hub skill
hermes skills uninstall k8s

# 解除 bundled skill 的 "user-modified" 狀態
hermes skills reset google-workspace
# 連同刪除本地編輯、還原原版
hermes skills reset google-workspace --restore
```

---

### 4.3.8 發布 Skill 到 GitHub

```bash
# 將本地 skill 發布至 GitHub repo（需 repo write permission）
hermes skills publish skills/my-skill --to github --repo owner/repo

# 加入自訂 GitHub 來源
hermes skills tap add myorg/skills-repo
```

---

## 4.4 預期結果（標示示意或實測）

| 操作 | 可觀察證據 |
|------|------------|
| `hermes skills install official/research/arxiv` | `hermes skills list --source hub` 顯示 arxiv；`/skills search arxiv` 可見 |
| `/arxiv "transformers"` | Agent 載入 skill、呼叫 `skill_view`、回傳論文列表 |
| 自建 `git-summary` skill | `hermes skills list` 含 git-summary；`/git-summary` 輸出 commit 列表 |
| `/learn "Python requests"` | `~/.hermes/skills/` 新增 skill 目錄、含 `SKILL.md` 與 `references/` |
| `hermes skills check` | 列出有上游變更的 skills；`update` 後 hash 更新 |

---

## 4.5 常見失敗與恢復

| 症狀 | 可能原因 | 恢復步驟 |
|------|----------|----------|
| `/skills install` 失敗、顯示 "blocked by scanner" | Skill 觸發 dangerous verdict | 1. 閱讀 scanner findings 2. 確認無惡意碼後可 `--force`（風險自負） |
| 安裝後 slash command 不出現 | Skill 名稱衝突、目錄結構錯誤 | 1. `hermes skills list` 確認安裝 2. 檢查 `SKILL.md` 的 `name:` 欄位 3. 重啟 session |
| `/learn` 產出的 skill 不完整 | 素材太少、工具未啟用（如需 web search 但 toolset 關閉） | 1. 提供更多素材或啟用相關 toolset 2. 再次 `/learn` 合併更新 |
| `hermes skills update` 失敗 | 本地編輯衝突、上游 repo 變更結構 | 1. 備份本地編輯 2. `--force` 強制更新 3. 手動合併變更 |
| WSL2 下 scripts/ 腳本無法執行 | 權限、路徑分隔符、line ending | 1. `chmod +x script.sh` 2. 確保 LF line ending 3. 使用 `bash script.sh` 明確呼叫 |

---

## 4.6 安全提醒

- **Community / URL / GitHub 安裝的 skill 預設不受信任**，security scanner 會阻擋 dangerous verdict，** `--force` 不能繞過 dangerous 阻擋**
- `blueprint:` 排程技能會在背景執行，**請審閱 prompt 內容**，避免非預期副作用
- `required_environment_variables` 會提示使用者輸入，**請勿**在 skill 範例中寫入真實 secret
- `references/` 檔案雖按需載入，**仍可能包含敏感資訊**，發布前請審查
- `hermes skills publish` 需 GitHub write permission，**請確認 repo 所有權**再執行
- 共用環境下，`~/.hermes/skills/` 為用戶級目錄，**不同用戶技能隔離**

---

## 4.7 練習

1. **基礎**：`hermes skills browse --source official` 找一個感興趣的 skill，安裝並呼叫一次
2. **進階**：建立一個個人常用的 skill（如「生成 commit message」、「轉換 Markdown 到 Notion 格式」），包含 `references/` 至少一個檔案
3. **挑戰**：用 `/learn` 從一份技術規格文件（或網址）生成 skill，驗證產出的 `SKILL.md` 結構、呼叫一次、再用 `hermes skills check` 確認無上游更新（因為是本地生成）

---

## 4.8 完成條件

- [ ] 能用 `hermes skills browse/search/install` 從 Hub 安裝一個 skill 並成功呼叫
- [ ] 能建立一個自訂 skill（含 `SKILL.md`、`references/`），並驗證 slash command 運作
- [ ] 能使用 `/learn` 從素材生成 skill，並說明產出結構
- [ ] 能執行 `hermes skills check` / `update` / `audit` 並解讀結果
- [ ] 能解釋 bundled / official / trusted / community 四種信任等級的差異

---

## 4.9 本章小結

Skill 讓 Hermes 從「單次對話」進化為「可重複的自動化單元」。核心工作流：**瀏覽 → 安裝 → 呼叫 → 驗證 → 維護（check/update/audit）**。自建 skill 遵循 `SKILL.md` 標準格式，善用 `references/` 實現按需載入，`/learn` 更能將非結構化知識快速轉為可執行技能。安全上，**永遠審閱社群 skill 的 scanner 結果**，生產環境優先使用 bundled/official/trusted 來源。

---

## 4.10 官方來源與延伸閱讀

- Working with Skills：https://hermes-agent.nousresearch.com/docs/guides/work-with-skills
- Skills 系統完整文件：https://hermes-agent.nousresearch.com/docs/user-guide/features/skills
- GitHub 同步文件：https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/skills.md
- Skills Hub：https://hermes-agent.nousresearch.com/docs/skills/
- 建立 Skills 開發指南：https://hermes-agent.nousresearch.com/docs/developer-guide/creating-skills
- Bundled Skills Catalog：https://hermes-agent.nousresearch.com/docs/reference/skills-catalog
- 原始碼：`hermes_cli/subcommands/skills.py`