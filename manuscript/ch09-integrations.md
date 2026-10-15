# 第 9 章：MCP、Webhook 與 Plugin

## 本章目標

本章完成後，你應能分辨三種整合方式：MCP 讓 Hermes 使用外部工具，Webhook 讓外部事件觸發 Hermes，Plugin 則擴充 Hermes 本身。你也能建立一個受控的測試整合、驗證結果，並在不需要時移除它。

## 9.1 三種整合方式

| 方式 | 方向 | 適合情境 |
|---|---|---|
| MCP | Hermes → 外部工具 | GitHub、資料庫、檔案系統、內部 API |
| Webhook | 外部服務 → Hermes | GitHub issue、CI/CD、Stripe、監控警報 |
| Plugin | 擴充 Hermes | 新工具、平台、介面、slash command |

如果你要「查詢 GitHub issue」，先考慮 MCP；如果要「GitHub 新增 issue 時叫醒 Hermes」，使用 Webhook；如果要「增加 Hermes 原生功能」，才考慮 Plugin。

## 9.2 MCP：讓 Hermes 使用外部工具

先查看官方 Catalog：

```bash
hermes mcp catalog
```

互動式安裝：

```bash
hermes mcp
```

或安裝指定項目：

```bash
hermes mcp install NAME
```

完成後查看和測試：

```bash
hermes mcp list
hermes mcp test NAME
hermes mcp configure NAME
```

MCP 工具分為兩種常見連線方式：

- stdio：Hermes 在本機啟動 command，透過標準輸入輸出通訊。
- HTTP／Streamable HTTP：Hermes 連接遠端 MCP URL。

本機 stdio 設定概念：

```yaml
mcp_servers:
  time:
    command: "uvx"
    args: ["mcp-server-time"]
```

遠端 HTTP 設定概念：

```yaml
mcp_servers:
  company_api:
    url: "https://mcp.example.com/mcp"
    auth: oauth
```

設定完成後要重新啟動 Hermes。啟動時 Hermes 會探索 server 提供的工具，工具名稱通常以 server 名稱加前綴，例如：

```text
mcp_time_get_current_time
mcp_github_list_issues
```

### MCP 驗證

不要只看到「安裝完成」就算成功。依序確認：

```bash
hermes mcp list
hermes mcp test NAME
hermes
```

在對話中提出一個真的需要該工具的低風險請求，並核對工具名稱、輸入和回傳結果。若工具沒有出現，檢查 `mcp_servers` 設定名稱、`npx`／`uvx` 是否在 PATH、server 是否需要 OAuth 或 API key。

### MCP 安全

- 安裝前檢查 server 的來源、command、args 和 bootstrap 指令。
- 只啟用真正需要的 MCP tools。
- 不要把整個 shell environment 傳給不信任的 server。
- API key 只透過明確的 `env` 或安全設定提供。
- 不信任的 MCP server 可以停用 sampling。
- 新增或移除 server 後重新啟動 Hermes，避免誤以為舊 session 已更新。

## 9.3 Webhook：讓外部事件觸發 Hermes

先啟用 Webhook adapter：

```bash
hermes gateway setup
```

再確認：

```bash
hermes webhook list
```

Gateway 運作後測試健康端點：

```bash
curl http://localhost:8644/health
```

建立一個事件訂閱：

```bash
hermes webhook subscribe github-issues \
  --events "issues" \
  --prompt "收到 GitHub issue：{issue.title}\n作者：{issue.user.login}\n動作：{action}\n請整理問題重點並提出分流建議。" \
  --deliver telegram \
  --deliver-chat-id "CHAT_ID"
```

查看、測試和移除：

```bash
hermes webhook list
hermes webhook test github-issues
hermes webhook remove github-issues
```

Webhook 的基本流程是：

```text
外部服務 POST
    ↓
驗證 secret／signature
    ↓
篩選 event 與 payload
    ↓
產生 Hermes prompt
    ↓
執行 agent
    ↓
送回 Telegram、Discord、GitHub comment 或 log
```

### Webhook 驗證

建立訂閱後，先用內建測試：

```bash
hermes webhook test github-issues \
  --payload '{"action":"opened","issue":{"title":"測試問題"}}'
```

確認三件事：

1. route 名稱正確。
2. event filter 接受測試事件。
3. delivery target 收到結果。

正式接收事件時，外部服務必須能連到 Hermes 的公開 URL。只監聽 `localhost` 時，GitHub 等外部服務無法連線；需要公開伺服器、反向代理或安全 tunnel。

### Webhook 安全

每個 route 都應使用 HMAC 或平台支援的 secret 驗證。有效簽章只證明請求持有 secret，不代表 issue title、commit message 或 alert 內容可信。對網際網路公開的 route：

- 使用最小 toolset。
- 不要讓摘要 route 自動執行危險命令。
- 保留 destructive command approval。
- 優先使用明確欄位，例如 `{issue.title}`，不要無限制注入整個 payload。
- 對廣泛事件使用 filter 或 script，避免每個事件都喚醒 agent。

## 9.4 Plugin：擴充 Hermes 本身

先搜尋官方 Plugin Catalog：

```bash
hermes plugins search KEYWORD
hermes plugins browse
```

查看 Plugin 後再安裝：

```bash
hermes plugins show NAME
hermes plugins install NAME
```

管理 Plugin：

```bash
hermes plugins list
hermes plugins enable NAME
hermes plugins disable NAME
hermes plugins capabilities
hermes plugins doctor
hermes plugins update NAME
hermes plugins remove NAME
```

安裝後應先執行 `plugins doctor`，再測試它宣稱提供的功能。Plugin 的 capability 是權限邊界，不是裝飾資訊；安裝前先確認它需要哪些檔案、網路、指令或平台權限。

## 9.5 小型整合練習

選擇一個低風險目標：

- MCP：列出一個測試目錄的檔案。
- Webhook：接收一個測試 JSON 並送到本機 log。
- Plugin：安裝一個官方 Catalog Plugin，查看其 capability。

完成後保存：

```text
使用的命令
實際工具或 route 名稱
預期結果
實際結果
測試時間
移除或停用方式
```

練習結束後清理測試項目：

```bash
hermes mcp remove NAME
hermes webhook remove NAME
hermes plugins disable NAME
```

只移除你實際建立的項目，不要用模糊名稱批次刪除。

## 9.6 常見問題

### MCP server 找不到

檢查 `command -v npx` 或 `command -v uvx`，再確認套件名稱和參數。若是遠端 server，檢查 URL、OAuth 和網路連線。

### Webhook health 正常但沒有事件

Health endpoint 只證明本機 adapter 在監聽，不代表外部服務能連到它。再檢查公開 URL、event type、secret、route path 和防火牆。

### Plugin 已安裝但功能不見

執行：

```bash
hermes plugins list
hermes plugins doctor
```

確認 Plugin 已 enable，然後重新啟動 Hermes。不要只看安裝目錄判斷功能已載入。

## 本章完成條件

- 你能說明 MCP、Webhook 和 Plugin 的方向與用途差異。
- 你能安裝或設定一個低風險 MCP，並用 `hermes mcp test` 驗證。
- 你能建立、測試和移除一個 Webhook subscription。
- 你能查看 Plugin capability 並執行診斷。
- 你能說明外部 payload、MCP server 和 Plugin 權限的安全邊界。

## 官方來源

- MCP：<https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp>
- Webhook：<https://hermes-agent.nousresearch.com/docs/user-guide/messaging/webhooks>
- Hermes Plugin：<https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins>
- Hermes CLI：<https://hermes-agent.nousresearch.com/docs/reference/cli-commands>
