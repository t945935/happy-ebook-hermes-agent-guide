# 研究來源彙整：第 3、4、9 章

本文件記錄撰寫 `manuscript/ch03-model-provider.md`、`manuscript/ch04-skills.md`、`manuscript/ch09-integrations.md` 時參考的官方文件、CLI 原始碼與實測指令來源。

---

## 第 3 章：設定模型與 API Provider

### 官方文件

| 主題 | URL | 擷取日期 | 備註 |
|------|-----|----------|------|
| CLI 指令參考 | https://hermes-agent.nousresearch.com/docs/reference/cli-commands | 2026-10-15 | `hermes model`、`hermes setup`、`hermes auth`、`hermes fallback` 完整參數與範例 |
| Fallback Provider | https://hermes-agent.nousresearch.com/docs/user-guide/features/fallback-providers | 2026-10-15 | fallback 鏈結構、觸發條件、支援場景、設定優先順序 |
| Provider 整合指南 | https://hermes-agent.nousresearch.com/docs/integrations/providers | 2026-10-15 | 各 Provider 設定方式、OAuth 流程、API key 存放、custom endpoint |
| 模型設定指南 | https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models | 2026-10-15 | `hermes model` vs `/model` 差異、session/global 範圍、reasoning effort |
| 快速入門 | https://hermes-agent.nousresearch.com/docs/getting-started/quickstart | 2026-10-15 | `hermes setup --portal`、provider 選擇表、常見故障排除 |
| 新增 Provider 開發指南 | https://hermes-agent.nousresearch.com/docs/developer-guide/adding-providers | 2026-10-15 | Provider 註冊流程、auth.py、models.py、runtime_provider.py、main.py 接點 |
| Provider 執行期解析 | https://hermes-agent.nousresearch.com/docs/developer-guide/provider-runtime | 2026-10-15 | 解析優先順序、plugins/model-providers/ 架構 |

### 原始碼參考

| 檔案 | 相關功能 |
|------|----------|
| `hermes_cli/setup.py` | `setup_model_provider()`、快速設定路徑、provider ready 檢查 |
| `hermes_cli/auth.py` | `PROVIDER_REGISTRY`、credential resolution、OAuth device code / PKCE |
| `hermes_cli/models.py` | `_PROVIDER_MODELS`、catalog fallback、provider labels、aliases |
| `hermes_cli/runtime_provider.py` | `resolve_runtime`、custom endpoint 解析、api_mode 判定 |
| `hermes_cli/main.py` | `select_provider_and_model()`、`_model_flow_*()`、CLI `--provider` choices |

### 實測指令（待驗證）

```bash
# 以下指令需在有 Hermes 環境的機器上實測，目前為文獻記錄
hermes model                    # 互動式 provider + model picker
hermes setup --portal           # Nous Portal 一鍵設定
hermes auth list                # 列出所有 credential pools
hermes auth add openrouter --api-key sk-or-xxx
hermes auth add anthropic --type oauth
hermes auth status anthropic
hermes fallback                 # 互動式 fallback 管理
hermes fallback add openrouter anthropic/claude-sonnet-4
hermes config get model --json
hermes status
```

### 未驗證項目

- 各 Provider 的實際 OAuth 流程畫面與回呼 URL
- `hermes auth add openai-codex --browser` 在 SSH tunnel 下的行為
- Custom endpoint 的 `key_cmd` 動態金鑰解析
- `fallback_providers` 鏈在多輪對話中的實際切換行為
- Windows/WSL2 下的環境變數優先順序與 `.env` 讀取

---

## 第 4 章：Skills 的建立與使用

### 官方文件

| 主題 | URL | 擷取日期 | 備註 |
|------|-----|----------|------|
| Working with Skills | https://hermes-agent.nousresearch.com/docs/guides/work-with-skills | 2026-10-15 | `/skills`、Hub 瀏覽、安裝、slash command 呼叫、skill_view 工具 |
| Skills 系統完整文件 | https://hermes-agent.nousresearch.com/docs/user-guide/features/skills | 2026-10-15 | SKILL.md 格式、Hub 來源、`/learn`、security scan、update lifecycle |
| GitHub 同步文件 | https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/skills.md | 2026-10-15 | 同上，含原始碼連結 |
| Skills Hub 首頁 | https://hermes-agent.nousresearch.com/docs/skills/ | 2026-10-15 | 註冊表統計、分類瀏覽 |
| 建立 Skills 開發指南 | https://hermes-agent.nousresearch.com/docs/developer-guide/creating-skills | 2026-10-15 | 目錄結構、frontmatter 完整欄位、blueprint、security scanning、發布流程 |
| Bundled Skills Catalog | https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | 2026-10-15 | 內建 skills 列表、分類、`hermes skills reset --restore` |

### 原始碼參考

| 檔案 | 相關功能 |
|------|----------|
| `hermes_cli/subcommands/skills.py` | `hermes skills browse/search/install/inspect/list/check/update/audit/uninstall/reset/publish/snapshot/tap` 完整參數定義 |

### 實測指令（待驗證）

```bash
hermes skills list
hermes skills browse
hermes skills browse --source official
hermes skills search kubernetes
hermes skills search react --source skills-sh
hermes skills inspect openai/skills/k8s
hermes skills install official/security/1password
hermes skills install https://sharethis.chat/SKILL.md
hermes skills install https://example.com/SKILL.md --name my-skill
hermes skills list --source hub
hermes skills check
hermes skills update
hermes skills audit
hermes skills uninstall k8s
hermes skills reset google-workspace
hermes skills reset google-workspace --restore
# 在 chat session 中：
/skills browse
/skills search react --source skills-sh
/skills install openai/skills/skill-creator --force
/learn <topic>
/ascii-art Make a banner
/plan Design a REST API
```

### 未驗證項目

- `/learn` 在不同介面（CLI、TUI、Dashboard、Gateway）的實際行為差異
- `references/` 下檔案的按需載入機制與 token 計算
- `requires_toolsets`、`fallback_for_toolsets` 的條件啟用邏輯
- `blueprint:` 排程技能的實際執行與 `hermes cron` 的關係
- Community skill 的 `--force` 安裝後是否仍受 scanner 封鎖
- `hermes skills publish` 的 GitHub repo 權限需求
- WSL2 下 skills 目錄權限與腳本執行

---

## 第 9 章：MCP、Webhook 與 Plugin

### 官方文件

| 主題 | URL | 擷取日期 | 備註 |
|------|-----|----------|------|
| MCP (Model Context Protocol) | https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp | 2026-10-15 | Catalog 安裝、OAuth、tool 選擇、manifest、更新機制 |
| Use MCP with Hermes | https://hermes-agent.nousresearch.com/docs/guides/use-mcp-with-hermes | 2026-10-15 | 步驟式安裝、`hermes mcp test`、stdio/HTTP、Windows/WSL Chrome devtools |
| MCP Config Reference | https://hermes-agent.nousresearch.com/docs/reference/mcp-config-reference | 2026-10-15 | `mcp_servers:` 完整 schema、`trust` tier、`tools` policy、reload |
| Webhooks | https://hermes-agent.nousresearch.com/docs/user-guide/messaging/webhooks | 2026-10-15 | 啟用方式、routes 設定、HMAC、dynamic subscribe、deliver targets、coalesce |
| Plugins | https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins | 2026-10-15 | Catalog 安裝、enable/disable、MCP allowlist、plugin hooks、ctx.call_mcp() |
| Plugin Catalog | https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog | 2026-10-15 | Catalog entry schema、pinned SHA、install/update provenance、submission 流程 |
| Event Hooks | https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks | 2026-10-15 | Gateway/plugin/shell/outbound hooks 對照表、payload 欄位、隱私提醒 |
| How to Configure MCP Safely | https://hermes-agent.ai/how-to/configure-mcp-servers | 2026-10-15 | 實務建議、Docker 路徑解析、profile 隔離 |
| Dashboard Admin Panel PR | https://github.com/NousResearch/hermes-agent/pull/36736 | 2026-10-15 | MCP catalog UI、webhook enable toggle、hook create/delete、system stats |

### 原始碼參考

| 檔案 | 相關功能 |
|------|----------|
| `hermes_cli/webhook.py` | `hermes webhook subscribe/list/remove/test`、config 載入、setup hint |
| `gateway/platforms/webhook.py` | disabled route 403 rejection、HMAC 驗證、GitHub/GitLab 事件處理 |
| `hermes_cli/plugins.py` (推測) | `hermes plugins search/browse/info/install/update/remove/enable/disable/doctor/check-dependencies/adopt` |
| `optional-mcps/*/manifest.yaml` | Catalog MCP manifest 結構、bootstrap、transport、source URL |

### 實測指令（待驗證）

```bash
# MCP
hermes mcp                  # 互動式 picker
hermes mcp catalog          # 純文字列表
hermes mcp install deepwiki
hermes mcp configure linear
hermes mcp test deepwiki
hermes mcp add codex --preset codex
hermes mcp add open_scaffold --command npx --args -y open-scaffold@latest mcp serve --repo /abs/path
hermes mcp login n8n-official
/reload-mcp

# Webhook
hermes gateway setup        # 啟用 webhook adapter
# 環境變數：
# WEBHOOK_ENABLED=true
# WEBHOOK_PORT=8644
# WEBHOOK_SECRET=your-secret
hermes webhook subscribe github-issues --events "issues" --prompt "..." --deliver telegram --deliver-chat-id "-100123456789"
hermes webhook list
hermes webhook test github-issues --payload '{"issue": {"number": 42, "title": "Test"}}'

# Plugin
hermes plugins search telegram
hermes plugins browse
hermes plugins info touchdesigner
hermes plugins install touchdesigner
hermes plugins enable touchdesigner
hermes plugins install user/repo --enable
hermes plugins update my-plugin
hermes plugins remove my-plugin
hermes plugins disable my-plugin
hermes plugins doctor my-plugin
hermes plugins check-dependencies my-plugin
hermes plugins adopt my-plugin
```

### 未驗證項目

- MCP server 的 `trust: untrusted` 在 write tool 觸發 approval 的實際行為
- Streamable HTTP vs SSE transport 的連線行為差異
- `hermes mcp test` 的 exit code 0/1/3 在腳本中的實用性
- Webhook `deliver_only: true` 的零 LLM 成本路徑實測
- Event coalescing (`coalesce.key`, `window_seconds`) 在高頻事件下的去重效果
- Plugin MCP allowlist 的 per-server 權限邊界測試
- `ctx.call_mcp()` 在 plugin hook 中的 timeout 與錯誤處理
- Catalog plugin update 時的 local edits autostash/reapply 機制
- `hermes plugins adopt` 對 self-cloned 目錄的掃描與驗證
- WSL2 下 stdio MCP server 的 command 路徑解析
- Multi-profile gateway 下 MCP / webhook / plugin 的隔離行為

---

## 共同參考

- AGENTS.md：專案規範、編輯規則、Git 規則、交接格式
- notes/writing-plan.md：寫作計劃、章節模板、完成條件、Phase 執行順序
- notes/agent-assignments.md：分工表、協作規則、各 Agent 任務提示
- notes/chapter-status.yaml：章節狀態追蹤

---

## 版本敏感標記

以下命令、設定鍵、功能可能隨 Hermes 版本變更，撰寫時需標示版本或標註「待驗證」：

| 項目 | 可能變更處 | 標註建議 |
|------|------------|----------|
| `hermes model` provider 清單 | 新增/移除 provider | 「截至 2026-10 版本」 |
| `hermes setup --portal` 流程 | OAuth scope、Tool Gateway 選項 | 「以官方文件為準」 |
| `hermes auth` subcommands | 新增 `refresh`、`priority` 等 | 列出文件版本 |
| `fallback_providers` vs `fallback_model` | legacy key 遷移 | 「當前版本以 fallback_providers 為主」 |
| Skills Hub 來源 | 新增 skills-sh、clawhub、lobehub 等 | 列出文件列舉的 sources |
| `/learn` 產出格式 | knowledge-base skill 結構 | 「依據 2026 版本實作」 |
| MCP catalog entries | 新增/移除 optional-mcps | 「安裝前請執行 `hermes mcp catalog` 確認」 |
| Webhook `deliver` targets | 新增平台 | 列出文件表格內容 |
| Plugin catalog schema | 新增欄位 | 參考 plugin-catalog README |
| `hermes plugins validate` | CI 檢查項目 | 「提交前請實測」 |

---

## 待補充實測證據

完成章節撰寫後，需在實際 Hermes 環境執行並記錄：

1. 第 3 章：完整 provider 設定流程（含 OAuth、API key、custom endpoint）、fallback 觸發測試
2. 第 4 章：從 Hub 安裝一個 skill、建立一個自訂 skill、`/learn` 產出驗證、`hermes skills check/update`
3. 第 9 章：安裝一個 catalog MCP、設定一個 webhook route、安裝一個 catalog plugin、測試 MCP allowlist

所有實測輸出需保留在本地，不提交至 repository；僅在章節中標示「實測環境：Hermes vX.Y.Z、Linux/macOS/WSL2」等資訊。