# 附錄 B：設定與秘密安全

## 哪些資料是秘密

以下資料不能放進 Git、Issue、截圖或聊天：

- API key
- OAuth access token 和 refresh token
- Telegram／Discord bot token
- Webhook secret
- 密碼、CVC、私密 SSH key

Hermes 的一般設定與秘密應分開管理：

```text
~/.hermes/config.yaml   一般設定
~/.hermes/.env          API key 與其他秘密
```

不要把整個 `.env` 貼給其他人。回報問題時，只提供變數名稱，不提供值。

## 外部訊息平台

Telegram 和 Discord 應使用 allowlist：

```text
TELEGRAM_ALLOWED_USERS
DISCORD_ALLOWED_USERS
DISCORD_ALLOWED_ROLES
```

不要在有工具權限的 Bot 上直接啟用所有使用者。群組 session 也要先決定是每位使用者分開，還是整個群組共用。

## 危險指令

Hermes 對部分 shell 操作會要求確認。一般使用維持預設 approval；不要把：

```bash
hermes --yolo
```

當成一般故障排除手段。它會略過危險指令確認，適合的使用情境非常有限。

## MCP 與 Webhook

MCP server 和 Webhook payload 都是外部輸入。啟用前：

1. 檢查來源和啟動命令。
2. 只啟用需要的工具。
3. 不把不可信內容直接當成管理指令。
4. Webhook 使用 HMAC 或平台提供的簽章驗證。
5. 對網際網路公開的 route 優先使用沙箱、容器或最小 toolset。

有效簽章只證明請求持有 secret，不代表 payload 裡的標題、留言或文字值得信任。

## Dashboard 與公開服務

Dashboard 在本機使用時，優先綁定 loopback，再使用 SSH tunnel 進行遠端管理。不要把沒有適當認證的管理介面直接公開在網際網路。

## 安全檢查清單

- [ ] 秘密只在安全的 secret store 或 `.env`。
- [ ] Git repository 沒有秘密和私人日誌。
- [ ] 訊息平台有 allowlist。
- [ ] Webhook 有簽章驗證。
- [ ] MCP 只開啟必要工具。
- [ ] 危險命令 approval 沒有被永久關閉。
- [ ] 發布、付款、刪除和外部訊息操作保留人工確認。
