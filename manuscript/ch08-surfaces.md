# 第 8 章　Desktop、Dashboard 與 TUI

## 本章目標

本章帶你在另一種介面開啟第 2 章的「週末讀書練習」，確認看到原有歷史，再繼續一輪對話。你可以完成 TUI 或 Dashboard 路線；Desktop 是有圖形環境時的延伸練習。

本章於 2026-10-15 核對官方文件，並在 WSL 的 Hermes `v0.21.1 (2026.9.7)` 實際執行 CLI help 與隔離設定測試。**本次沒有啟動 TUI、Dashboard 或 Desktop，沒有驗證 GUI、WebSocket、登入或跨介面聊天成功。**以下介面步驟是可供讀者驗收的文件流程，不是本機成功畫面的轉述。

## 適用讀者與前提

你需要一個能實際聊天的 Hermes 安裝，以及第 2 章建立的 session ID。若尚未做過第 2 章，先建立一段無秘密的互動式對話，再用 `hermes sessions list --limit 5` 找到它。

TUI 需要互動式終端機與可用的前端執行環境；Dashboard 需要其 HTTP 與前端相依套件；Desktop 需要作業系統的 GUI 支援。來源安裝與完整 Desktop 套件的相依套件取得方式不同，缺少套件時要對照自己的安裝方式處理。[安裝指南](https://hermes-agent.nousresearch.com/docs/getting-started/installation)

## 核心概念：選介面，也要選對資料

| 介面 | 入口 | 適合的工作 | 本章主要驗證 |
| --- | --- | --- | --- |
| 傳統 CLI | `hermes --cli` | 文字互動、故障排查 | 介面切回後仍能找到原 session |
| TUI | `hermes --tui` | 終端機內的 session、模型與工作狀態操作 | 載入既有歷史、查看用量、切換 live session |
| Dashboard | `hermes dashboard` | 瀏覽器內管理設定、sessions 與狀態 | 本機連線、既有 session、服務狀態 |
| Desktop | `hermes desktop` 或官方應用程式 | 原生視窗中的聊天與管理 | 實際視窗、正確 backend 與歷史 |

它們使用同一套 Hermes 核心；在**相同資料目錄、profile 與 backend** 的前提下，可以共用設定與 session。這不代表 Windows 原生安裝會自動看見 WSL 的資料，也不代表另一台電腦的 Desktop 自動連到你的伺服器。找不到歷史時，先檢查連到哪一份資料，而不是重新輸入整段對話。[Desktop](https://hermes-agent.nousresearch.com/docs/user-guide/desktop)、[Sessions](https://hermes-agent.nousresearch.com/docs/user-guide/sessions)

Dashboard 是瀏覽器管理介面；其中的 Chat 頁以終端機橋接方式提供 TUI。Desktop 則有自己的原生聊天介面，不需要先在本機開啟 Dashboard 才能當作一般桌面程式使用。遠端 backend 另有連線與認證要求，不能把它和本機視窗混為一談。

## 路線 A：在 TUI 接續讀書計畫

### 步驟 1：確認 session 並啟動

在原本使用 Hermes 的同一環境執行：

```text
hermes sessions list --limit 5
hermes --tui --resume SESSION_ID
```

把 `SESSION_ID` 換成第 2 章對話的實際 ID。等待介面載入完成，查看是否有原來「星期六兩小時、星期日一小時」的內容。確認歷史後才輸入：

```text
請根據這段對話最新的讀書計畫，寫一句下次開始閱讀前要看的提醒。只回答文字，不使用工具。
```

**預期證據：**TUI 顯示原有對話，並增加這一輪訊息與回答。不要只看畫面是否比較漂亮；session 正確與模型能回答才是這條路線的驗收點。[TUI 啟動與續接](https://hermes-agent.nousresearch.com/docs/user-guide/tui)

若只是想開新對話，使用 `hermes --tui`。想接續最近的對話，可以用 `hermes --tui --continue`；但本章使用精確 ID，避免多個工作目錄或不同來源的最近 session 判定造成混淆。

### 步驟 2：查看 model、usage 與 agents

在 TUI 輸入區依序輸入，下列不是 shell 命令：

```text
/help
/model
/usage
/agents
```

每次先讀完畫面，再關閉面板後執行下一個命令。

| 面板 | 這次要做的事 | 可觀察證據 |
| --- | --- | --- |
| `/help` | 查找本章用到的命令 | 清單中有實際可用項目 |
| `/model` | 檢查目前 Provider／模型；沒有切換需求就取消 | 模型名稱與你設定的一致 |
| `/usage` | 閱讀 token、context 與費用資訊 | 能指出一個用量數字，或辨認目前無法取得的欄位 |
| `/agents` | 查看是否有子代理人工作 | 單純文字練習沒有子代理人也是正常結果 |

`/agents` 是觀察入口，打開它不會因此完成一次多代理人任務；真正的分派留到第 5 章。費用顯示可能是估算或不可用，不能當成 Provider 帳單保證。這些面板依官方 TUI 文件與本機隨附文件核對，未在此次終端機實際點選。[TUI 操作說明](https://hermes-agent.nousresearch.com/docs/user-guide/tui)

### 步驟 3：分清 live session 與已儲存歷史

完成當前回覆後輸入 `/sessions`，以方向鍵選擇、Enter 切換、Esc 關閉面板。官方 TUI 文件說明這個切換器列的是目前 TUI 程序中的 live sessions；已關閉的歷史不一定列在這裡。

若要練習兩個 live sessions，先記下目前讀書計畫的 ID，再輸入 `/sessions new`，建立一個空白 session。重新打開 `/sessions`，選回讀書計畫並確認歷史仍在。不要把選取器中的關閉操作當成刪除永久歷史。

如果沒有出現預期項目，離開介面後用 `hermes sessions list --limit 5` 查歷史，再以 `hermes --tui --resume SESSION_ID` 重開。這條命令路線也適合處理快捷鍵被終端機攔截的情況。

### 步驟 4：決定是否設為預設介面

先讀目前值並記在私人筆記：

```text
hermes config get display.interface
```

確定喜歡 TUI 後再設定並讀回：

```text
hermes config set display.interface tui
hermes config get display.interface
```

**本機實測：**在獨立臨時 `HERMES_HOME`，`set` 退出 `0`，隨後 `get` 回傳 `tui`。這只證明設定寫入與讀回，沒有證明 TUI 視窗啟動成功。

下一次執行 `hermes` 便依設定選擇介面。若要暫時切回傳統 CLI，不必改檔案：

```text
hermes --cli
```

若要把長期預設改回 CLI：

```text
hermes config set display.interface cli
hermes config get display.interface
```

本機也實測讀回 `cli`，兩個命令皆退出 `0`。若你原本的值是 `tui`，練習後應依自己記錄的值復原。環境中的 `HERMES_TUI` 也可能影響選擇；明確的 `--cli`／`--tui` 旗標適合用來確認啟動的是哪個介面。

## 路線 B：在瀏覽器使用 Dashboard

### 步驟 1：只在本機啟動

先查是否已有伺服器，避免把既有工作誤認成這次練習：

```text
hermes dashboard --status
```

一般啟動命令是 `hermes dashboard`。本章採用明確位址、連接埠及不自動開瀏覽器的方式，適合 WSL 或遠端終端機：

```text
hermes dashboard --host 127.0.0.1 --port 9119 --no-open
```

保留啟動中的終端機，依顯示訊息確認服務位址。使用同一台電腦的瀏覽器開啟 `http://127.0.0.1:9119`，再從另一個終端機執行 `hermes dashboard --status`。

**預期證據：**狀態命令列出伺服器，瀏覽器顯示 Hermes 頁面。兩項要一起確認：有程序不等於瀏覽器能連線；網頁載入也不等於模型已通過認證。

本機 help 確認預設 host 為 `127.0.0.1`、port 為 `9119`，並有 `--no-open`、`--status`、`--stop`。本次沒有真的開啟連接埠。[Web Dashboard](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard)

### 步驟 2：找回同一個 session

若畫面有 profile 切換器，先選擇第 2 章使用的 profile。在 Sessions 頁找「週末讀書練習」，核對 ID 與歷史；依目前文件，session 旁的播放按鈕可進入 Chat 頁並載入該 session。

確認原計畫出現後，再送出一個無秘密的簡短追問。等回答完成後，回到 Sessions 或重新載入同一個 ID，核對新訊息仍然存在。這比只看到狀態頁更完整地驗證了 session、聊天連線與模型服務。

目前 Dashboard 文件說明 Chat 頁隨一般啟動提供，不需要另加 `--tui`；本機 `hermes dashboard --help` 也沒有這個旗標。不要把頂層的 `hermes --tui` 選項搬到 `dashboard` 後面。

**平台限制：**目前官方 Dashboard 文件仍指出內嵌 Chat 終端機需要 POSIX PTY；Windows 原生的管理頁可用，不代表其 Chat 頁也可用。遇到該限制，改由 WSL2 啟動 Dashboard，或使用 Windows 原生 Desktop。不要因為 Chat 頁失敗就認定整個 Windows Hermes 安裝不受支援。

### 步驟 3：結束這次測試

先確認所有相關對話已完成，再查看：

```text
hermes dashboard --status
```

若這台機器上列出的 Dashboard 服務都屬於你這次要停止的工作，才執行：

```text
hermes dashboard --stop
hermes dashboard --status
```

`--stop` 的本機 help 寫的是停止所有執行中的 Hermes web server 程序，不能當成「只關掉目前瀏覽器分頁」。共用機器若還有其他使用者或 profile 的工作，不要用這個命令清場。

**預期證據：**最後一次狀態查詢不再列出已停止的服務。關閉瀏覽器分頁與停止伺服器是兩件事。

## Dashboard 認證與 SSH tunnel

Dashboard 可以管理秘密與執行工作，應視為管理入口。預設 loopback 綁定限制了網路可達範圍；它不會阻止同一台機器上有權存取本機服務的人，也不代表使用雲端 Provider 時資料不會離開電腦。

目前官方文件與本機 help 一致指出：非 loopback 綁定會啟用認證要求，需有密碼或 OAuth Provider；`--insecure` 已是棄用的無作用旗標，不能再用來關閉認證。這裡不以公開綁定作為初學者練習。[Dashboard 認證說明](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard)

若 Hermes 在你有 SSH 權限的伺服器，可保留遠端 loopback 綁定。在遠端執行：

```text
hermes dashboard --host 127.0.0.1 --port 9119 --no-open
```

在自己的電腦另開終端機，將 `USER`、`SERVER` 換成 SSH 帳號與主機：

```bash
ssh -N -o ExitOnForwardFailure=yes -L 127.0.0.1:19119:127.0.0.1:9119 USER@SERVER
```

維持 SSH 連線，瀏覽器開啟 `http://127.0.0.1:19119`。第一個 `127.0.0.1:19119` 是你電腦上的入口，後面的 `127.0.0.1:9119` 是由 SSH 伺服器那一端存取的 Dashboard。`-N` 不執行遠端 shell 命令；`-L` 建立本機轉送。此範例依 OpenSSH 文件整理，**本次未建立 tunnel 或驗證 Hermes 的 Host／WebSocket 檢查**。[OpenSSH ssh(1)](https://man.openbsd.org/ssh.1)

驗證仍須做到「看到歷史並完成回覆」。若網頁開得出來但 Chat 無法連線，檢查 Dashboard 與瀏覽器顯示的認證／WebSocket 錯誤，不要靠取消安全檢查修復。Ctrl+C 結束 SSH 轉送後，遠端 Dashboard 可能仍在執行，需另外依前述流程管理。

## Desktop：有 GUI 時的延伸路線

已有 CLI 來源安裝的環境，可先查 help，再啟動：

```text
hermes desktop --help
hermes desktop
```

本機 help 說明此入口預設會安裝 workspace 的 Node 相依套件、建置目前作業系統的 Electron 應用程式並啟動。因此第一次啟動可能包含下載與建置，不能把「命令存在」解讀成「完整桌面套件已就緒」。若使用官方完整 Desktop 套件，則依對應平台的套件安裝流程操作。[Desktop](https://hermes-agent.nousresearch.com/docs/user-guide/desktop)、[Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation)

視窗出現後，核對目前 backend、profile 與 session 清單；找到讀書計畫，讀到原提示詞，再送一個簡短追問。**視窗開啟、backend ready、實際收到回答是不同層次的證據。**Desktop 顯示另一套空白歷史時，先檢查是否連到了另一個本機或遠端 backend。

官方文件提供 Settings → Gateways 的遠端連線路線；它需要遠端 backend 已在執行，並滿足認證與連線要求。本章不假設原生 Windows Desktop 自動連到 WSL，也不要求複製秘密檔到兩邊來「同步」。

## WSL2 的 GUI 限制與替代路線

先區分三件事：TUI 在終端機內繪製、Dashboard 在瀏覽器顯示、Desktop 則需要 Linux 或 Windows 的視窗系統。Linux 的 TUI 不需要因為有「UI」兩個字就另外安裝 WSLg。

Microsoft 的 GUI 文件要求 WSL2，以及支援的 Windows 版本與顯示驅動；它不提供完整的 Linux 桌面環境保證。即使有 `DISPLAY` 或 `WAYLAND_DISPLAY` 變數，也只表示存在顯示設定線索，不能證明 Electron 視窗、GPU、剪貼簿或音訊全部正常。本次 WSL 檢查發現這兩個變數都有設定，但沒有實際啟動 Desktop。[WSL GUI 條件](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps)

沒有可用 GUI 或 Desktop 啟動失敗時，依需要採用以下路線：

1. 只需要聊天：在 WSL 的互動式終端機執行 `hermes --tui`；若前端本身失敗，先用 `hermes --cli` 排查。
2. 想用瀏覽器管理：在 WSL 執行 `hermes dashboard --host 127.0.0.1 --port 9119 --no-open`，先在 Windows 瀏覽器試 `http://localhost:9119`。一般 localhost 轉送可行，但實際結果受 WSL 網路模式與設定影響，不能承諾所有機器都相同。
3. 想用原生 Windows 視窗：依官方 Windows 路線安裝 Desktop。它預設使用 Windows 的資料；若需要 WSL 那份歷史，另按官方遠端 backend 流程設定與驗證。

Windows 瀏覽器連不上時，先從 WSL 內確認 Dashboard 是否真的存在，再核對 Windows→WSL 的網路方向與 localhost 轉送設定。`0.0.0.0` 不是瀏覽器網址；也不要為了讓網頁打開，就把管理介面直接暴露到整個網路。[Hermes WSL2 網路指南](https://hermes-agent.nousresearch.com/docs/user-guide/windows-wsl-quickstart)

## 常見失敗與恢復

| 症狀 | 恢復流程 | 驗證方式 |
| --- | --- | --- |
| TUI 沒顯示或掉回 CLI | 用真正互動式終端機，閱讀啟動診斷；以 `hermes doctor` 核對 Node／相依套件；先用 `hermes --cli` 確認核心聊天 | TUI 重新啟動後能載入指定歷史 |
| 設了 TUI 仍開 CLI | `hermes config get display.interface` 讀回設定，核對環境與 profile，改用明確 `--tui` 驗證 | 啟動的是預期介面 |
| Dashboard 提示 port 已占用 | 先看 `--status`；不要停止不明服務，可改用 `--port 9120` 並同步修改瀏覽器網址 | 狀態與網址使用同一連接埠 |
| Dashboard 缺少套件或前端 build | 依目前安裝方式與錯誤訊息修復；舊版手動來源安裝與新版受管理 runtime 的依賴流程不同 | 狀態頁與 session 頁均可開啟 |
| 管理頁能看，但 Chat 不通 | 核對 POSIX PTY 平台限制、TUI 相依套件、profile 與認證／WebSocket 錯誤 | 既有 session 能收到新回覆 |
| 找不到既有 session | 核對 backend、profile、Windows／WSL 邊界，再用精確 ID | 畫面有第 2 章原提示詞 |
| Desktop 視窗未出現 | 區分建置錯誤與顯示環境錯誤；WSL 改走 TUI 或瀏覽器，依 Microsoft 文件修復 GUI | 實際視窗與聊天都成功，才算 Desktop 通過 |

日誌入口可先用 `hermes logs --help` 確認；例如 `hermes logs gui -n 20` 或 `hermes logs desktop -n 20`。閱讀後只保留去除秘密的摘要。本次只驗證 help，沒有收集使用者的既有 GUI 日誌。

## 安全提醒

切換介面不會自動減少工具或帳號權限。Dashboard 的設定表單、API Keys 頁面與 Desktop 的設定仍可能改到同一份資料；先辨認目前 profile，再儲存變更。不要把管理畫面、認證資訊或含私人對話的截圖直接公開。

介面關閉、session 關閉與後端工作停止不可互相替代。停止服務前先確認工作狀態，避免中斷你或他人的長時間任務。

## 練習與完成條件

選 TUI 或 Dashboard 任一路線，打開第 2 章的 session，完成一輪追問，再回到 CLI 用相同 ID 找到新增內容。若練習了 `display.interface`，讀回設定並按原值復原；若啟動了專用 Dashboard，確認服務已依你的意圖停止。

完成時，你應能出示自己的 session ID 與兩種介面中一致的歷史，並解釋：TUI 使用終端機、Dashboard 使用瀏覽器、Desktop 使用原生視窗；三者共用資料有環境與 profile 前提。WSL 使用者還應能說明自己採用哪條 GUI 或替代路線。

## 本章小結

選擇介面的關鍵是能否完成工作、讀取正確歷史並理解後端位置。遇到 GUI 或網路問題時，回到已驗證的 CLI 與精確 session ID，可以縮小問題範圍。

## 官方來源與延伸閱讀

- [TUI](https://hermes-agent.nousresearch.com/docs/user-guide/tui)：啟動、預設介面與操作面板。
- [Web Dashboard](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard)：位址、Chat、認證、遠端存取。
- [Desktop](https://hermes-agent.nousresearch.com/docs/user-guide/desktop)：本機與遠端 backend。
- [Platform Support](https://hermes-agent.nousresearch.com/docs/getting-started/platform-support)、[Windows WSL2](https://hermes-agent.nousresearch.com/docs/user-guide/windows-wsl-quickstart)：平台與網路邊界。
- [Microsoft WSL GUI](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps)、[OpenSSH ssh(1)](https://man.openbsd.org/ssh.1)：GUI 前提與轉送語法。
- 本次實測與未驗證清單見 `research/codex-ch01-ch02-ch08-sources.md`。
