# 多 Agent 寫作分工

## 協作規則

- 工作目錄：`/home/j5/happy-ebook-hermes-agent-guide`
- GitHub：<https://github.com/t945935/happy-ebook-hermes-agent-guide>
- 所有 Agent 開始前必讀：`AGENTS.md`、`notes/writing-plan.md`、`notes/chapter-status.yaml`
- 各 Agent 只修改自己的章節檔與自己的 `research/` 檔案；不要修改其他 Agent 的章節、根目錄 README、寫作計劃或狀態總表。
- Hermes 負責整合、更新狀態、統一格式、交叉引用與最後提交。
- 每個 Agent 完成後必須回報檔案、來源、實測命令、未驗證內容、阻塞事項和下一步。
- 不得把 API key、OAuth token、bot token、Webhook secret、個人絕對路徑或私有日誌提交到 Git。

## 總分工

| Agent | 角色 | 負責範圍 | 交付檔案 |
|---|---|---|---|
| Hermes | 總編輯與整合者 | 前言、第 10 章、附錄、狀態、整合與最終審查 | `manuscript/00-foreword.md`、`manuscript/ch10-troubleshooting.md`、`manuscript/a-command-reference.md`、`manuscript/b-security.md`、`manuscript/c-reader-support.md` |
| Codex | 基礎操作與命令驗證 | 第 1～2 章：安裝、初始設定、CLI | `manuscript/ch01-installation.md`、`manuscript/ch02-cli.md`、`research/codex-ch01-ch02-sources.md` |
| OpenCode | Provider 與 Skills | 第 3～4 章：模型／API provider、Skills | `manuscript/ch03-model-provider.md`、`manuscript/ch04-skills.md`、`research/opencode-ch03-ch04-sources.md` |
| Pi | 自動化與 Gateway | 第 5～7 章：delegate_task、訊息平台、Cron | `manuscript/ch05-delegation.md`、`manuscript/ch06-messaging.md`、`manuscript/ch07-cron.md`、`research/pi-ch05-ch07-sources.md` |
| Antigravity | 介面與外部整合 | 第 8～9 章：Desktop／Dashboard／TUI、MCP／Webhook／Plugin | `manuscript/ch08-surfaces.md`、`manuscript/ch09-integrations.md`、`research/antigravity-ch08-ch09-sources.md` |

## 執行順序

### Phase 1：平行撰寫

Codex、OpenCode、Pi、Antigravity 同時撰寫各自章節。每個 Agent 不得等待其他章節才能完成自己的獨立說明；遇到跨章節依賴時，使用「待整合」標記並回報 Hermes。

### Phase 2：Hermes 整合

Hermes 依序處理：

1. 讀取四組交付檔案與研究來源
2. 檢查章節標題、命令、設定鍵和版本說法
3. 統一術語：Provider、Skill、Gateway、session、toolset、Webhook、MCP
4. 將重複內容移到附錄或前言
5. 補上跨章節先決條件與交叉引用
6. 更新 `notes/chapter-status.yaml`
7. 執行完整結構檢查與 `git diff --check`

### Phase 3：第二輪審查

- Codex：只讀審查第 1～4 章的命令和設定
- Pi：只讀審查第 5～7 章的流程和安全邊界
- Antigravity：只讀審查第 8～9 章的介面與整合說法
- Hermes：整合所有審查，不讓審查 Agent 直接覆寫他人章節

## 各 Agent 任務提示

### Codex

```text
你負責本書第 1～2 章。先閱讀 AGENTS.md、notes/writing-plan.md、notes/chapter-status.yaml。

撰寫：
- manuscript/ch01-installation.md
- manuscript/ch02-cli.md
- research/codex-ch01-ch02-sources.md

使用目前官方 Hermes 文件和實際 CLI help 驗證命令。每章必須包含目標、前提、工作情境、完整步驟、預期結果、故障恢復、安全提醒、練習、完成條件、小結和來源。不要修改其他章節或共用狀態檔。完成後回報實際執行過的命令與未驗證範圍。
```

### OpenCode

```text
你負責本書第 3～4 章。先閱讀 AGENTS.md、notes/writing-plan.md、notes/chapter-status.yaml。

撰寫：
- manuscript/ch03-model-provider.md
- manuscript/ch04-skills.md
- research/opencode-ch03-ch04-sources.md

重點驗證 hermes model、hermes setup、hermes auth、fallback、Skills Hub、SKILL.md、/learn 和 Skill slash command。區分官方文件、實際執行、示意設定。不要修改其他章節或共用狀態檔。完成後回報實測證據、來源與未驗證內容。
```

### Pi

```text
你負責本書第 5～7 章。先閱讀 AGENTS.md、notes/writing-plan.md、notes/chapter-status.yaml。

撰寫：
- manuscript/ch05-delegation.md
- manuscript/ch06-messaging.md
- manuscript/ch07-cron.md
- research/pi-ch05-ch07-sources.md

重點說明 delegate_task 的邊界、Telegram／Discord allowlist 與 token 安全、Gateway、Cron 的建立測試暫停恢復和 delivery。不要把子代理人自我報告當成完成證據。不要修改其他章節或共用狀態檔。完成後回報實測命令和跨平台未驗證範圍。
```

### Antigravity

```text
你負責本書第 8～9 章。先閱讀 AGENTS.md、notes/writing-plan.md、notes/chapter-status.yaml。

撰寫：
- manuscript/ch08-surfaces.md
- manuscript/ch09-integrations.md
- research/antigravity-ch08-ch09-sources.md

重點說明 Desktop、Dashboard、TUI 的差異與啟動方式，以及 MCP、Webhook、Plugin 的安裝、測試、安全和移除。務必區分 WSL、Windows、Linux、macOS 的限制。不要修改其他章節或共用狀態檔。完成後回報實測命令、官方來源與無法實測的 GUI／遠端部分。
```

### Hermes

```text
你是總編輯與整合者。先閱讀 AGENTS.md、notes/writing-plan.md、notes/chapter-status.yaml 和 notes/agent-assignments.md。

負責：
- 前言：本書路線與安全邊界
- 第 10 章：故障排除與維護
- 三個附錄
- 接收四組 Agent 交付、整合、審查和更新狀態

在所有章節完成前不要宣稱書稿完成。先檢查每章是否有讀者成果、完整步驟、驗證、恢復、安全提醒和官方來源，再進行全書交叉引用和術語統一。保留未驗證事項，不要用示意輸出取代實測證據。
```

## 完成判定

各章只有在下列項目全部具備後，才能由 Hermes 標記為 `reviewed`：

- 正文檔案存在且內容完整
- 讀者成果明確
- 有可重做的工作情境
- 有實作步驟與預期證據
- 有故障恢復
- 有安全提醒
- 有官方來源或實測記錄
- 已完成交叉引用與術語審查
- `git diff --check` 通過

「Agent 回覆完成」不等於章節完成；必須讀回檔案並驗證實際內容。
