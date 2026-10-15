# Hermes Agent 操作手冊：寫作計劃

## 1. 書籍定位

書名：Hermes Agent 操作手冊
副標題：從第一次安裝到多平台 AI 助理
作者：Happy eBook Authors
出版者：Happy eBook

本書是一份以實作為主的 Traditional Chinese 指南，帶讀者從安裝 Hermes Agent 開始，逐步完成模型設定、CLI 操作、Skills、多代理人、Cron、多平台 Gateway、Desktop／Dashboard／TUI，以及 MCP、Webhook 與 Plugin 整合。每章都要讓讀者產生可觀察、可重做的結果。

讀者服務 Repository：
https://github.com/t945935/happy-ebook-hermes-agent-guide

## 2. 讀者與前提

目標讀者：

- 第一次使用 Hermes Agent 的讀者
- 熟悉終端機但不熟悉 AI agent 的讀者
- 想把 Hermes 接到 Telegram、Discord 或自動化流程的技術使用者
- 想建立 Skills、MCP 或 Plugin 工作流的開發者

最低前提：

- 能開啟終端機並執行基本指令
- 具備基本檔案與目錄概念
- 擁有至少一個可用的模型 Provider，或準備使用 Nous Portal
- 需要訊息平台、Webhook、MCP 或 Plugin 的章節時，再準備對應帳號與服務

平台範圍：

- Linux、macOS、Windows、WSL2
- Windows／WSL 的差異必須明確標示
- 不把某一作者工作站的路徑、使用者名稱或設定當成讀者通用前提

## 3. 寫作原則

1. 先完成一個最小可用聊天，再增加 Gateway、Cron、Skills、MCP 等功能。
2. 每個操作都要有「目的 → 前提 → 指令 → 預期結果 → 驗證 → 故障恢復」。
3. 所有版本、命令、設定鍵和平台能力都以目前官方文件為準。
4. API key、OAuth token、Telegram／Discord bot token 絕不放進書稿中的真實值。
5. 範例輸出若未實際執行，標示為「示意輸出」；不能把示意結果寫成已驗證結果。
6. 安全章節必須提醒 allowlist、secret 管理、Webhook 驗證、MCP 權限與危險指令 approval。
7. 讀者服務 Repository 只放讀者需要的補充資料和 Issues，不把未出版書稿或作者內部證據當成公開內容。

## 4. 章節總覽與完成條件

### 前言：本書路線與安全邊界

讀者成果：知道本書的學習路線，能判斷何時使用 CLI、TUI、Dashboard、Desktop 或 Gateway。

必備內容：

- Hermes Agent 是什麼
- 本書各章的依賴關係
- 「先讓普通聊天成功，再增加功能」的路線
- API key、OAuth、bot token 和 webhook secret 的基本安全規則
- 讀者服務 Repository 的用途與取得方式

完成條件：讀者能選擇下一章，並知道不應把秘密貼到聊天或 Git。

### 第 1 章：安裝與初始設定

讀者成果：在自己的平台安裝 Hermes，完成第一次可用對話。

必備內容：

- Linux／macOS／WSL2 安裝
- Windows 原生安裝路線
- `hermes --version`
- `hermes setup`、`hermes model`
- `hermes doctor`
- 設定檔與秘密檔的位置
- 第一次聊天與基本驗證
- 常見 PATH、Python、Node.js、權限問題

完成條件：讀者能執行一次實際聊天，並能用 `hermes doctor` 找出基本設定狀態。

### 第 2 章：CLI 指令與用法

讀者成果：能啟動、繼續、管理 Hermes 對話，並把 Hermes 用於單次命令與腳本。

必備內容：

- `hermes`、`hermes chat -q`
- `-z／--oneshot`
- `--model`、`--provider`、`--toolsets`
- `--continue`、`--resume`
- `sessions`、`logs`、`config`
- slash commands
- approval 與 `--yolo` 的安全界線

完成條件：讀者能建立一個 session、繼續它、匯出或查詢紀錄，並完成一次非互動式查詢。

### 第 3 章：設定模型與 API Provider

讀者成果：能選擇 provider、登入 OAuth、設定 API key provider，並驗證模型實際可用。

必備內容：

- `hermes model`
- `hermes setup --portal`
- `hermes auth status`、`hermes auth add`
- API key 存放方式
- custom／OpenAI-compatible endpoint
- fallback provider
- 模型切換與 session／全域範圍
- provider 失敗的診斷

完成條件：讀者能完成一次有工具呼叫的實際聊天，且能說明目前使用的 provider 與模型。

### 第 4 章：Skills 的建立與使用

讀者成果：能安裝、呼叫、檢查並建立一個可重複使用的 Skill。

必備內容：

- Skill 的用途與 progressive disclosure
- `hermes skills list／search／install／check`
- slash command 呼叫
- `/learn`
- `SKILL.md` 格式
- `references/` 的使用
- Skill 的觸發條件、流程、陷阱與驗證
- 平台與安全限制

完成條件：讀者能建立一個 Skill，呼叫它完成一項工作，並用 `hermes skills check` 檢查。

### 第 5 章：多代理人與 `delegate_task`

讀者成果：能把獨立工作拆給子代理人，平行執行並整合結果。

必備內容：

- 何時應分派、何時不應分派
- 單一子代理人與平行任務
- goal、context、輸出要求
- `leaf` 與 `orchestrator`
- 並行數與深度限制
- 背景任務不是永久任務
- 子代理人結果的驗證，而非只相信自我報告
- 長時間任務與 Cron／獨立 Hermes 程序的差異

完成條件：讀者能完成一個至少含兩個獨立子任務的平行工作，並核對每個子任務的檔案或測試證據。

### 第 6 章：Telegram、Discord 與其他訊息平台

讀者成果：能設定一個受 allowlist 保護的訊息平台 Bot。

必備內容：

- Gateway 架構
- `hermes gateway setup／start／status／restart`
- Telegram BotFather、token、user ID、Privacy Mode
- Discord Developer Portal、Message Content Intent、權限與 user ID
- DM、群組、Thread、session 隔離
- `/new`、`/model`、`/status`、`/sethome`
- 安全 allowlist 與不應直接開放所有使用者
- 日誌與斷線排查

完成條件：讀者能從 Telegram 或 Discord 發出訊息，收到 Hermes 回覆，並確認未授權使用者不能使用。

### 第 7 章：Cron 排程

讀者成果：能建立、測試、暫停與移除一個定時任務，並把結果送到指定位置。

必備內容：

- `hermes cron status／list／create／run／pause／resume／remove`
- duration、every phrase、cron expression
- `--deliver`
- `--workdir`、`--skill`、`--model`
- `--script` 與 `--no-agent`
- `--continuity`
- 執行紀錄與失敗處理
- Gateway、systemd、WSL2 的長期執行注意事項

完成條件：讀者能建立一個測試排程、手動觸發、查看執行紀錄，並清理測試任務。

### 第 8 章：Desktop、Dashboard 與 TUI

讀者成果：能依使用情境選擇並啟動適合的 Hermes 介面。

必備內容：

- 三種介面的定位與共用資料
- `hermes --tui`、`hermes --cli`
- `display.interface`
- TUI session、model、agents、usage 操作
- `hermes dashboard`、port、status、stop
- `hermes desktop`
- WSL2 的 GUI 限制與替代路線
- Dashboard 的本機綁定位址、認證與 SSH tunnel

完成條件：讀者能啟動 TUI 或 Dashboard，切換一個既有 session，並能解釋三種介面的差異。

### 第 9 章：MCP、Webhook 與 Plugin

讀者成果：能安全地加入一個 MCP 工具或 Webhook route，並理解 Plugin 的安裝與權限邊界。

必備內容：

- MCP client 與 MCP server 的角色
- `hermes mcp catalog／install／list／test／configure`
- stdio 與 HTTP MCP
- tool prefix 與工具選擇
- Webhook 啟用、健康檢查、subscription、test、remove
- HMAC、payload 不可信、filter 與 script
- Plugin 的 `search／browse／install／list／enable／disable／doctor`
- MCP、Webhook、Plugin 的選擇表

完成條件：讀者能測試一個 MCP 或 Webhook，能查看其連線／事件結果，並能移除它。

### 第 10 章：故障排除與維護

讀者成果：能從診斷、設定、認證、日誌和最小重現開始處理常見問題。

必備內容：

- `hermes doctor`
- `config check`
- `auth status`
- `logs errors／-f`
- 設定變更後的 reset／restart 規則
- provider、tool、Skill、Gateway、Discord、MCP、Webhook、Cron 的症狀表
- WSL2 systemd 與 linger
- 安全修復與 `--yolo` 的界線
- 如何提供乾淨的錯誤報告

完成條件：讀者能將一個問題分類，收集不含秘密的診斷資訊，並完成一個可驗證的修復或明確定位阻塞點。

### 附錄 A：指令速查表

- 按使用情境整理，而不是只按字母排序
- 每個指令附用途、是否會改變狀態、是否需要重啟

### 附錄 B：設定與秘密安全

- `.env`、`config.yaml`、OAuth、bot token、Webhook secret
- allowlist、approval、MCP 權限、公開 Dashboard

### 附錄 C：讀者服務與回報問題

- Repository URL
- GitHub Issues 使用方法
- 回報版本、平台、指令、錯誤訊息和重現步驟
- 絕不提交秘密

## 5. 建議執行順序

### Phase 0：規格與研究

- 固定書名、讀者、平台範圍與安全原則
- 以官方文件建立每章來源清單
- 確定目前 Hermes 版本與需要標示的版本敏感命令
- 產生章節狀態表

### Phase 1：核心操作路線

- 前言、第 1～3 章
- 先確保讀者能安裝、設定模型並完成普通聊天
- 每章完成一個最小可驗證任務

### Phase 2：能力擴充

- 第 4～7 章
- Skills、多代理人、Gateway、Cron
- 優先使用可在本機重做的練習

### Phase 3：介面與整合

- 第 8～9 章
- TUI、Dashboard、Desktop、MCP、Webhook、Plugin
- 特別檢查安全與外部服務依賴

### Phase 4：維護與出版前檢查

- 第 10 章與附錄
- 全書命令、設定鍵、URL、版本與交叉引用檢查
- 讀者服務內容檢查
- Markdown、程式碼 fence、章節順序和狀態表檢查
- 另行進行 EPUB／PDF 生產與驗證；本 Repository 不自動等於公開書稿或 ebook 發布區

## 6. 每章標準模板

每個 `manuscript/chNN-*.md` 應包含：

1. 本章目標
2. 適用讀者與前提
3. 核心概念
4. 實作情境
5. 步驟與指令
6. 預期結果（標示示意或實測）
7. 常見失敗與恢復
8. 安全提醒
9. 練習
10. 完成條件
11. 本章小結
12. 官方來源與延伸閱讀

## 7. 章節交付標準

章節作者交付前必須：

- 完成指定章節全文，而不是只交標題或大綱
- 逐一檢查所有命令、設定鍵與 URL
- 把未實測內容標為示意或待驗證
- 提供至少一個可觀察的成功證據
- 提供至少一個與本章相關的失敗恢復流程
- 執行 `git diff --check`
- 在交接訊息中列出修改檔案、來源、實測命令、限制和下一步

## 8. 機器可讀的完成定義

只有同時符合以下條件，章節才能標為 `reviewed`：

- `draft_exists`: 章節檔案存在且非空
- `reader_outcome`: 有明確讀者成果
- `worked_procedure`: 有完整操作流程
- `verification`: 有可觀察驗證方式
- `recovery`: 有失敗恢復說明
- `sources`: 有官方來源或明確實測證據
- `safety`: 有本章相關安全邊界
- `editor_review`: 已由整合者檢查交叉引用與一致性

## 9. 跨 Agent 交接格式

```text
[HANDOFF]
Task: CH03 設定模型與 API Provider
Status: completed | partial | blocked
Changed files:
- manuscript/ch03-model-provider.md
- research/ch03-sources.md
Sources:
- URL or command
Executed:
- command -> exit code / observed result
Verification:
- what was actually verified
Unverified:
- claims still requiring current docs or environment
Blockers:
- none / details
Next task:
- suggested follow-up
[/HANDOFF]
```
