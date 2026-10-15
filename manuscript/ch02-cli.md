# 第 2 章　CLI 指令與用法

## 本章目標

本章用一份「週末讀書計畫」練習建立對話、找到 session、繼續討論並匯出紀錄，最後把一次查詢放進腳本。你會知道哪些指令在作業系統的 shell 執行，哪些是在 Hermes 的輸入區使用。

核對日期為 2026-10-15。本機 `v0.21.1 (2026.9.7)` 的 CLI help 已實際執行；本章聊天、續接、匯出與模型請求是**文件流程，尚未端到端實測**。不把本文的提示詞或預期結果當成作者的成功紀錄。

## 適用讀者與前提

先完成第 1 章的實際聊天。準備一個自己控制、沒有秘密的練習目錄，並記下使用的 Provider 與模型名稱。後面出現的 `SESSION_ID`、`PROVIDER_ID`、`MODEL_ID` 都是佔位符，必須換成你實際查到的值。

腳本範例以 Bash 為主；PowerShell 的退出碼讀法另外列出。不要在 PowerShell 原封不動貼入 Bash 的變數或條件判斷語法。

## 核心概念：四個操作入口

| 入口 | 使用時機 | 要辨認的輸出 |
| --- | --- | --- |
| `hermes`／`hermes --cli` | 來回對話 | 輸入區、歷史、互動狀態 |
| `hermes chat -q "提示詞"` | 用命令列提供第一個問題 | 是否繼續留在互動介面，取決於 TTY 與旗標 |
| `hermes -z "提示詞"` | 腳本取得最後回答 | help 定義 stdout 只放最後回答，沒有 banner 或 session ID 行 |
| `hermes sessions …`、`hermes config …` | 管理歷史或設定 | 管理命令的結果，不是模型回答 |

`-q` 與 `-z` 不可混為一談。本機 `hermes chat --help` 明確說明：在真正的互動式終端機中，`-q` 會把問題當成互動 session 的第一輪；搭配 `--oneshot`、`-Q` 或非 TTY 輸入輸出，才回答後退出。官方 CLI 頁的簡短例子仍把 `-q` 寫成單次查詢，因此本章需要一次後退出時，明寫 `hermes chat --oneshot -q`。[CLI 介面](https://hermes-agent.nousresearch.com/docs/user-guide/cli)

另外，頂層的 `hermes --oneshot "提示詞"` 等同 `hermes -z "提示詞"`，但 `hermes chat --oneshot` 是搭配 `-q` 或 `--query-file` 的布林旗標。先看命令所在層級，再看旗標，不要只搜尋同一個單字。

## 實作情境：保留並接續一份讀書計畫

### 步驟 1：建立第一輪對話

在練習目錄執行：

```text
hermes --cli
```

輸入以下**練習提示詞**：

```text
我要在週末讀完一本入門書。星期六有兩小時，星期日有一小時。請用繁體中文排成三個閱讀時段，只回答文字，不使用工具。
```

等待回答完成。自行核對總時數是否三小時、是否分成三個時段；不能只因為有文字就判定答案正確。接著輸入 `/help`，閱讀此版本實際提供的互動命令，再以 `/quit` 離開。

**預期證據：**對話含有你的時間限制及完整回答。若仍在執行工具或工作，先處理當前工作；新版 Gateway 型 CLI 關閉用戶端可能只會中斷顯示連線，工作仍在背景繼續。[CLI 生命週期說明](https://hermes-agent.nousresearch.com/docs/user-guide/cli)

### 步驟 2：找到並命名 session

回到 shell：

```text
hermes sessions list --limit 5
```

依建立時間、內容摘要或標題找到剛才的對話，複製實際 session ID。若同時開著多個 Hermes 視窗，不要直接假設第一列就是這次練習。

把以下的 `SESSION_ID` 換掉後執行：

```text
hermes sessions rename SESSION_ID "週末讀書練習"
hermes sessions list --limit 5
```

**預期證據：**同一個 ID 出現新的標題。命名讓人容易辨識；ID 則適合精確指定。Hermes 會保存 session 與訊息歷史，預設使用資料目錄中的 `state.db`。[Sessions](https://hermes-agent.nousresearch.com/docs/user-guide/sessions)

**本機實測的界線：**`list`、`rename`、`export` 的 help 皆退出 `0`。獨立空白測試目錄中的 `hermes sessions list --limit 5` 退出 `0` 並顯示 `No sessions found.`；這只驗證空清單查詢，沒有假裝建立過模型對話。

### 步驟 3：繼續同一段討論

仍在同一練習環境，以精確 ID 開啟：

```text
hermes --cli --resume SESSION_ID
```

確認畫面載入剛才的時間限制，再問：

```text
延續剛才的三個閱讀時段，每個時段各加一項讀後自我檢查，不增加總時數。
```

**預期證據：**載入的歷史與回答確實接續原計畫，不是空白的新對話。回答完成後退出，再列一次 sessions，確認你能找到這段工作。

熟悉 ID 後，也可使用以下不同的續接方式；每次練習選一種即可：

```text
hermes --continue
hermes --continue "週末讀書練習"
hermes --resume latest
```

不帶名稱的 `--continue` 與 `latest` 會做最近 session 的查找；目前文件還描述終端機與工作目錄範圍的判定，不宜把它理解成所有介面的全域最新一筆。若接錯對話，退出後用清單中的確切 ID 重試。續接也可能恢復原工作目錄，開始要求檔案操作前先核對所在位置。[續接與工作目錄](https://hermes-agent.nousresearch.com/docs/user-guide/sessions)

### 步驟 4：匯出一份可檢查的紀錄

先確認這個 session 只包含本章無秘密的練習內容。以 Markdown 匯出到練習目錄下的專用資料夾：

```text
hermes sessions export --session-id SESSION_ID --format md --redact ./session-export
```

這裡最後一個參數是**輸出目錄**，不是單一 Markdown 檔名。依命令顯示的位置打開匯出檔，檢查兩輪提示詞、回答與選定的 session 是否相符。若需要 JSONL，格式不同，輸出參數是檔案：

```text
hermes sessions export --session-id SESSION_ID --format jsonl --redact ./reading-session.jsonl
```

**預期證據：**檔案存在，而且你真的讀過內容。`--redact` 不能取代人工檢查；人名、內部資訊和不常見的秘密格式仍可能出現在紀錄中。本練習只做本機匯出，不需要上傳、刪除原 session 或覆寫既有匯出檔。[CLI 命令參考](https://hermes-agent.nousresearch.com/docs/reference/cli-commands)

## 單次查詢與腳本

### 明確回答一次後離開

```text
hermes chat --oneshot -q "請把『先閱讀，再整理，最後練習』改寫成一句繁體中文提醒。只回答文字，不使用工具。"
```

這適合從 shell 直接給問題。不要假設它的輸出與 `-z` 完全相同：本機 help 對 `chat -Q` 描述為最後回答加 session 資訊，頂層 `-z` 則排除 session ID 行。需要把回答存檔時，可使用：

```bash
hermes -z '請把「先閱讀，再整理，最後練習」改寫成一句繁體中文提醒。只回答文字，不使用工具。' > reminder.txt
hermes_rc=$?
if [ "$hermes_rc" -eq 0 ] && [ -s reminder.txt ]; then
  cat reminder.txt
else
  printf '本次查詢失敗或沒有可用回答，退出碼：%s\n' "$hermes_rc"
fi
```

這是**未實跑的 Bash 腳本範例**。`reminder.txt` 是你為練習選用的輸出檔，重跑會覆寫它。腳本先保存退出碼，再檢查檔案非空；即使兩者通過，仍應閱讀內容，確認它真的是回答而不是錯誤敘述。不要把模型輸出接到 `bash` 或其他執行器。

PowerShell 的對應最小操作為：

```powershell
hermes -z '請用繁體中文寫一句閱讀提醒。只回答文字，不使用工具。' > reminder.txt
$hermesExit = $LASTEXITCODE
$hermesExit
Get-Content ./reminder.txt
```

本機 help 與 `hermes_cli/oneshot.py` 都確認：**`-z` 會自動略過 approval，仍會載入一般工具、記憶與工作目錄規則。**安靜輸出不代表唯讀或低權限。本章只示範你自己撰寫的固定文字提示；若要處理外來文件或自動化真實工作，必須先確認可用工具、專案規則、hook 與執行帳號權限，不能依賴「不要使用工具」這句話隔離風險。

### 從檔案提供提示詞

先以編輯器建立 `prompt.txt`，寫入同一個無秘密的練習提示詞，再執行：

```text
hermes chat --oneshot --query-file prompt.txt
```

`--query-file` 與 `-q` 互斥。當文字包含引號、反引號或 `$()` 時，檔案入口可避免先被 shell 當成程式解讀；它不會消除文字交給模型後的提示注入風險。此用法已由 `hermes chat --help` 核對，未發出模型請求。

## 模型、Provider 與 toolset 的作用範圍

`hermes model` 用來選預設 Provider 與模型；啟動旗標則為這次啟動提供選擇。用你確定有權使用的值取代佔位符：

```text
hermes chat --provider PROVIDER_ID --model MODEL_ID --toolsets "web"
```

`--toolsets` 使用逗號分隔名稱，例如官方 CLI 範例的 `web,terminal,skills`。本章用 `web` 說明縮小選擇的方式，不表示你的搜尋服務已設定成功，也不把 toolset 選擇當成作業系統 sandbox。

頂層 `-z` 也接受 `--model`、`--provider`、`--toolsets`。本機原始碼檢查另發現：`-z` 若指定 `--provider`，需要同時有明確模型（或對應模型環境設定）；因此腳本應成對提供 Provider／模型，或一起使用已設定的預設值。

先在新 session 驗證選擇。新版 Gateway 型 CLI 對既有 session 的啟動選項有固定範圍，不能假設加上不同的 `--model` 再 `--resume` 就會改掉原 session。互動中的模型切換應先查 `/help`，再使用該介面提供的 `/model`。[CLI 選項與 Gateway 行為](https://hermes-agent.nousresearch.com/docs/user-guide/cli)

## slash commands、設定與日誌

shell 命令如 `hermes sessions list` 在 Hermes 外面執行；`/help` 這類 slash command 則輸入到 Hermes 對話區。不同版本與介面的 slash 清單可能不同；目前官方 CLI 頁已描述較精簡的 Gateway 型 CLI，而 TUI 頁仍有較完整的操作清單。以正在使用的 `/help` 為準，不要假設每個介面都有全部命令。

| 命令 | 操作位置與用途 |
| --- | --- |
| `/help` | 對話區；確認此介面可用命令 |
| `/model` | 支援的對話介面；查看或切換已設定模型 |
| `/quit` | 對話區；完成工作後離開介面 |
| `/usage`、`/sessions`、`/agents` | 第 8 章 TUI 練習；分別檢查用量、live sessions 與子代理人 |
| `hermes config get display.interface` | shell；讀取一個指定設定 |
| `hermes config check` | shell；檢查設定缺漏或更新需求 |
| `hermes logs errors -n 20` | shell；看最近的錯誤日誌 |
| `hermes logs --since 1h` | shell；縮小到最近一小時 |
| `hermes logs -f` | shell；持續觀察新增日誌，以 Ctrl+C 結束追蹤 |

設定修改範例是 `hermes config set display.interface tui`；它會影響後續啟動，本章不必先改，第 8 章會安排讀回與復原。日誌可能含提示詞、路徑和敏感資訊，先在本機閱讀；本次寫作沒有讀取或匯出使用者既有私有日誌。[Slash Commands](https://hermes-agent.nousresearch.com/docs/reference/slash-commands)、[CLI Commands](https://hermes-agent.nousresearch.com/docs/reference/cli-commands)

## 安全提醒：approval 與 `--yolo` 的界線

當介面要求批准工具或危險命令時，先讀實際操作內容、作用目錄與會修改的資料。批准應對應你理解的具體動作；若與讀書計畫無關，就拒絕並縮小任務。不要把 approval 當成所有副作用都必定會被攔下的保證。

`--yolo` 的 help 定義是略過危險命令批准提示。它不是修復 Provider、PATH 或 GUI 問題的方式，本章不以它排除故障。`-z` 的自動略過 approval 行為尤其容易被忽略；要將腳本搬到有重要資料的環境之前，先重新檢查權限與可用工具。

## 常見失敗與恢復

| 症狀 | 恢復流程 | 核對結果 |
| --- | --- | --- |
| `-q` 回答後仍停在介面 | 用 `/quit` 離開；下一次明寫 `chat --oneshot -q` | 回答後回到 shell |
| 找不到 session／接到別段對話 | 確認同一環境與 profile，執行 `sessions list`，改用精確 ID | 舊提示詞與時間限制都載入 |
| 匯出的內容過多 | 核對 `--session-id` 是否填入；改到新輸出目錄重做，再人工閱讀 | 只包含預期練習紀錄 |
| 指定模型失敗 | 回到 `hermes model` 核對帳號可用選項；先用新 session 測試 | 最小文字查詢成功 |
| 腳本輸出空白／非零退出 | 檢查 stderr 與 `hermes logs errors -n 20`，先用互動模式重現；不要無限重試 | 修復後有正確回答及退出碼 |
| slash command 不支援 | 查 `/help`；歷史管理改用 shell 的 `hermes sessions …`，完整 TUI 功能見第 8 章 | 可從正確入口完成同一操作 |

## 練習與完成條件

把讀書計畫改成「星期日只有半小時」，只在原 session 提出修訂，再匯出到新的資料夾，人工比較兩個版本。最後用單次查詢把你的新計畫整理成一句提醒。

完成本章需要你自己的四項證據：一個可辨識的 session ID、一次成功載入原歷史的續接、一份已讀過且無秘密的匯出檔，以及一次回答後確實退出的非互動式查詢。你也應能解釋為什麼 `-z` 不只是「比較安靜的聊天」。

## 本章小結

CLI 不只用來聊天，也提供可追蹤的 session 與腳本入口。用精確 ID、讀回匯出內容、保留退出碼，才能把「執行過命令」變成可檢查的工作成果。

## 官方來源與延伸閱讀

- [CLI Interface](https://hermes-agent.nousresearch.com/docs/user-guide/cli)：啟動、旗標與新版 Gateway 型 CLI 的限制。
- [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands)：sessions、logs、config。
- [Sessions](https://hermes-agent.nousresearch.com/docs/user-guide/sessions)：歷史與續接。
- [Slash Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/slash-commands)：互動命令，須再與目前介面的 `/help` 核對。
- [本機版本的 oneshot 實作](https://github.com/NousResearch/hermes-agent/blob/05d705dd695d1084388529124dc2ffe5ce919e89/hermes_cli/oneshot.py)：本次讀碼核對的 approval 與 Provider／模型限制。
- 命令退出結果與未驗證範圍見 `research/codex-ch01-ch02-ch08-sources.md`。
