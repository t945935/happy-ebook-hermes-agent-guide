# 第 10 章：故障排除與維護

## 本章目標

完成本章後，你應能把 Hermes 問題分類，收集不含秘密的診斷資料，先排除最常見的設定和認證錯誤，再決定是否需要重啟、重新登入或提交問題回報。

## 10.1 四步診斷法

先不要反覆重試同一個命令。依序執行：

```bash
hermes --version
hermes doctor
hermes config check
hermes auth status
```

如果問題與 Gateway、Cron 或訊息平台有關，再執行：

```bash
hermes gateway status
hermes cron status
hermes logs errors
```

記錄命令的退出狀態、錯誤訊息、使用的工作目錄和 Hermes 版本。移除 API key、token、密碼和私人訊息後，才把結果放進 Issue。

## 10.2 模型與 Provider

症狀包括「沒有模型」、「API key not set」、「OAuth 過期」或請求被拒絕。先執行：

```bash
hermes model
hermes auth status
hermes auth list
```

API key provider 要檢查 `${HERMES_HOME:-~/.hermes}/.env` 是否有正確的環境變數；OAuth provider 則使用對應的登入流程重新建立認證。完成後重新測試：

```bash
hermes chat -q "請只回答：provider test ok"
```

不要把「登入狀態存在」當成「帳戶仍有額度」，也不要把某一個模型成功當成所有模型都可用。

## 10.3 工具、Skills 與設定沒有生效

查看工具：

```bash
hermes tools list
hermes skills list
hermes skills check
```

工具或 Skills 啟用後，舊 session 可能仍使用啟動時的工具清單。使用：

```text
/reset
```

或離開 CLI 後重新啟動 Hermes。Gateway 設定則使用：

```bash
hermes gateway restart
```

Skill 不出現時，確認名稱、平台啟用狀態和 `SKILL.md` 格式；也可暫時明確預載入：

```bash
hermes -s skill-name
```

## 10.4 Gateway、Telegram 與 Discord

先查看日誌：

```bash
hermes gateway status
hermes logs -f
```

Telegram 不回覆時，檢查 bot token、`TELEGRAM_ALLOWED_USERS`、群組 Privacy Mode 和 bot 是否已加入群組。先用 DM 測試，再測試群組。

Discord bot 上線但沉默時，檢查 Developer Portal 的 Message Content Intent，並確認 bot role 能讀取頻道、讀取歷史和傳送訊息。也要檢查 `DISCORD_ALLOWED_USERS` 或 `DISCORD_ALLOWED_ROLES`。

修改後：

```bash
hermes gateway restart
hermes gateway status
```

## 10.5 Cron 和 Webhook

Cron：

```bash
hermes cron list
hermes cron status
hermes cron doctor
hermes cron runs
```

先用 `hermes cron run JOB_ID` 手動觸發，確認問題是排程器還是任務本身。檢查 `--deliver` 目標是否已連線。

Webhook：

```bash
hermes webhook list
hermes webhook test ROUTE_NAME
curl http://localhost:8644/health
```

外部服務連不到本機時，檢查公開 URL、反向代理、防火牆和 tunnel。簽章錯誤時，確認外部服務和 Hermes 使用完全相同的 secret。有效簽章只代表來源通過驗證，不代表 payload 內容可信。

## 10.6 MCP 與 Plugin

MCP：

```bash
hermes mcp list
hermes mcp test SERVER_NAME
hermes mcp configure SERVER_NAME
```

常見原因是 `npx`、`uvx` 不在 PATH，遠端 URL 無法連線，OAuth 尚未完成，或 server 啟動命令錯誤。新增或移除 MCP 後，重新啟動 Hermes。

Plugin：

```bash
hermes plugins list
hermes plugins doctor
hermes plugins capabilities
```

先看 Plugin 宣告的來源與權限，再決定是否啟用；不要為了消除錯誤而授予不必要的檔案、網路或執行權限。

## 10.7 WSL2 與長時間服務

如果 WSL 關閉後 Gateway 消失，檢查 systemd：

```bash
systemctl --user status hermes-gateway
```

WSL2 要使用 systemd 服務，通常需要在 `/etc/wsl.conf` 啟用：

```ini
[boot]
systemd=true
```

修改後從 Windows PowerShell 執行：

```powershell
wsl --shutdown
```

重新進入 WSL 後，再檢查 Gateway。若不使用 systemd，背景服務可能在 shell 或 WSL 結束時停止。

## 10.8 如何回報問題

一份有效的回報應包含：

- Hermes 版本
- 作業系統與執行環境
- 相關命令
- 完整錯誤訊息，但已移除秘密
- 重現步驟
- `hermes doctor` 的相關結果
- 是否只在某個平台、某個模型或某個工具發生

不要只寫「不能用」。先判斷問題屬於模型、工具、設定、Gateway、外部平台或權限，其他人才能重現和處理。

## 本章完成條件

- 你能使用 `hermes doctor`、`config check` 和日誌開始診斷。
- 你能分辨認證、工具、Gateway、Cron、Webhook 和 MCP 問題。
- 你知道修改設定後何時要 `/reset`、重新啟動 CLI 或重啟 Gateway。
- 你能撰寫不含秘密且可重現的問題回報。
