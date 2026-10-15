# 前言：本書路線與安全邊界

## 本書要帶你完成什麼

本書的目標不是列出 Hermes Agent 的所有功能，而是帶你完成一條可以重做、可以驗證的使用路線：先安裝 Hermes，完成一次普通對話，再依需要加入模型、Skills、子代理人、訊息平台、排程和外部整合。

Hermes Agent 的不同介面共用同一個核心，但它們適合的工作不同：CLI 和 TUI 適合終端機操作，Dashboard 適合瀏覽器管理，Desktop 適合桌面工作，Gateway 則把助理接到 Telegram、Discord 等平台。

## 建議閱讀順序

1. 第 1 章：安裝並完成第一次對話。
2. 第 2～3 章：掌握 CLI、模型和 Provider。
3. 第 4～5 章：建立可重複的 Skills，並學會拆分任務。
4. 第 6～7 章：連接訊息平台和 Cron。
5. 第 8～9 章：選擇介面並加入 MCP、Webhook 或 Plugin。
6. 第 10 章與附錄：排錯、查指令和檢查安全設定。

每章都應回答四個問題：要先準備什麼、要執行什麼、成功時看見什麼、失敗時如何恢復。

## 先完成最小可用路線

第一次使用時，不要一開始就啟用所有功能。先執行：

```bash
hermes setup
hermes model
hermes chat -q "請只回答：Hermes Agent 正常運作"
hermes doctor
```

普通聊天尚未成功前，不要急著加入 Gateway、Cron、MCP 或多代理人。這樣遇到問題時，才容易分辨是模型連線、工具設定，還是整合服務造成的。

## 安全邊界

Hermes 可以讀寫檔案、執行指令、連接外部平台，因此請把它當成有權限的自動化工具：

- API key、OAuth token、bot token 和 webhook secret 不要貼在對話、Issue 或 Git repository。
- 將使用者和聊天 ID 放進 allowlist，不要為了測試長期開放所有人。
- 不要為了解決普通錯誤而使用 `--yolo`。
- 不信任的 Webhook payload、網頁、檔案和 MCP 工具輸出都要視為資料，不是管理員指令。
- 只啟用任務真正需要的工具和權限。
- 任何會刪除檔案、發布內容、傳送訊息或改變外部服務的操作，都應保留確認或審查步驟。

## 讀者服務

本書的讀者服務 repository 是：

https://github.com/t945935/happy-ebook-hermes-agent-guide

該 repository 用於勘誤、補充資料和問題回報。本書是獨立撰寫的操作指南，非 Nous Research 或 Hermes Agent 官方出版品；外部服務的訂閱、API 費用和帳號權限也不包含在書籍內。

## 本章完成條件

- 你能說明本書的學習路線。
- 你知道先完成普通聊天，再增加整合功能。
- 你知道秘密、allowlist 和危險操作 approval 的基本原則。
- 你能找到讀者服務 repository。
