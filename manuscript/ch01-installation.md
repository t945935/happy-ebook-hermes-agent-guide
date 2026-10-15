# 第 1 章　安裝與初始設定

## 本章目標

本章帶你從選擇安裝環境開始，完成模型設定、一次真正的文字對話，以及一次基本診斷。完成時，你應該能分辨「指令找得到」、「設定已儲存」和「模型真的回覆」這三種不同的證據。

本章於 2026-10-15 核對官方文件。本機命令驗證使用 Hermes Agent `v0.21.1 (2026.9.7)`、upstream `05d705dd`；這是實測版本，不代表當日最新版。下文標為「文件流程」的安裝、登入與聊天步驟尚未由本次寫作環境完整實跑。標為「本機實測」的結果只涵蓋明列的命令。

## 適用讀者與前提

準備一台能連上官方下載站與模型 Provider 的電腦、終端機，以及一個可用的 Provider 帳號。模型服務可能要求 API key、OAuth 登入或可用額度；安裝程式成功不會自動證明這些條件已滿足。

先選定本章要使用的環境：

| 環境 | 本章路線 | 先確認的事 |
| --- | --- | --- |
| Linux | 在 Linux shell 執行官方 `install.sh` | 發行版與 CPU 架構符合目前平台支援表 |
| macOS | 在終端機執行 `install.sh` | Apple Silicon 是目前主要支援路線；Intel 使用者先查平台表，別假設所有套件都有對應版本 |
| Windows 原生 | 在 PowerShell 執行 `install.ps1` | 使用 Windows 的指令與資料目錄 |
| Windows／WSL2 | 先進入 Linux 發行版，再執行 `install.sh` | Windows 與 WSL 是不同執行環境，設定與檔案不會自動合併 |

官方另有 Desktop 套件；本章先走 CLI 安裝，圖形介面留到第 8 章。目前平台表將 Linux／WSL2、Windows 與 Apple Silicon macOS 列為主要支援平台，也明確區分套件與架構限制。不要把搜尋結果中的 PyPI 或 Homebrew 安裝法當成官方支援路線。[平台支援表](https://hermes-agent.nousresearch.com/docs/getting-started/platform-support)

## 核心概念：程式、設定與模型是三個層次

Hermes 的啟動器負責找到程式與執行環境；設定決定使用哪個 Provider、模型與工具；真正送出訊息後，才會碰到模型服務的認證、額度與連線問題。因此，遇到失敗時應先找出卡在哪一層，而不是每次都重新安裝。

官方預設資料目錄在 Linux、macOS、WSL2 為 `~/.hermes/`，Windows 原生為 `%LOCALAPPDATA%\hermes\`。`HERMES_HOME` 可以改變資料位置；若使用 profile，也要確認目前選到哪一份設定。這些是產品的通用位置，不是要求你照抄作者電腦的目錄。[安裝位置說明](https://hermes-agent.nousresearch.com/docs/getting-started/installation)、[Windows 原生指南](https://hermes-agent.nousresearch.com/docs/user-guide/windows-native)

資料目錄中的 `config.yaml` 保存一般設定，`.env` 保存 API key 等秘密，`auth.json` 可保存 OAuth 認證資料。知道檔案的位置，是為了診斷與保護它們；本書的設定操作使用 `hermes config set` 或官方設定精靈，不要求手改 YAML。[設定指南](https://hermes-agent.nousresearch.com/docs/user-guide/configuration)

## 實作情境：建立一個可用的文字助理

這次只請 Hermes 幫你列出學習步驟。先不串訊息平台、不建立排程，也不要求它修改專案。請在你自己建立、沒有秘密或重要檔案的練習目錄操作，避免啟動時載入不熟悉的專案規則。

### 步驟 1：在正確的 shell 安裝

以下為**官方文件流程，未在本次環境重裝驗證**。下載後立即執行腳本會讓腳本以目前帳號權限運作；執行前核對網址與官方安裝頁。使用你平常操作 Hermes 的帳號，不要為了省事把整段安裝改成以 root 執行。

Linux、macOS、已進入 WSL2 的 Linux shell：

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

Windows 原生 PowerShell：

```powershell
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

兩段只選符合環境的一段。官方目前的來源安裝流程會準備受管理的執行環境與相依套件；不要把本章實測機器的 Python 版本當成新安裝的版本要求。首次安裝所需下載、系統函式庫與失敗重試方式，以當次安裝訊息及官方安裝頁為準。[安裝指南](https://hermes-agent.nousresearch.com/docs/getting-started/installation)

尚未安裝 WSL2 的讀者，可以先在系統管理員 PowerShell 依官方流程執行：

```powershell
wsl --install
```

依提示重新啟動 Windows，建立 Linux 使用者，再於 PowerShell 檢查：

```powershell
wsl --list --verbose
```

確認你要用的發行版是 `VERSION 2`，接著開啟該發行版的終端機，再執行上面的 Bash 安裝命令。`wsl --install` 不是在 Linux shell 裡執行的 Hermes 指令。[Hermes WSL2 指南](https://hermes-agent.nousresearch.com/docs/user-guide/windows-wsl-quickstart)

### 步驟 2：重新開啟終端機並確認啟動器

安裝完成後，關閉並重新開啟同一環境的終端機，讓 PATH 變更生效。WSL 使用者要重新開啟 Linux shell，不能改到 Windows PowerShell 後便期待找到同一個安裝。

```text
hermes --version
hermes --help
```

**預期證據：**第一個命令顯示版本，第二個顯示指令與選項。此時還沒有測試模型。

**本機實測：**兩個命令均退出 `0`；版本行為 `Hermes Agent v0.21.1 (2026.9.7) · upstream 05d705dd`。完整輸出另含安裝位置等機器資訊，本書不收錄那些私人路徑。若你的版本不同，請保留自己的版本行，後續用自己的 `--help` 核對。

### 步驟 3：設定 Provider 與模型

執行：

```text
hermes setup
```

這會開啟設定精靈。依畫面選擇你有帳號的 Provider、完成登入或輸入 API key，並選擇帳號實際可用的模型。其他功能可先保留預設或略過可選項目；不要把本章沒有用到的訊息平台憑證也全部填入。

若安裝時已完成精靈，只想重選 Provider 或模型，使用：

```text
hermes model
```

使用 Nous Portal 路線時，官方也提供 `hermes setup --portal`；它包含登入、選模型及 Tool Gateway 設定，不只是一般設定檢查。登入與 Provider 的完整比較留到第 3 章。上述命令本次只驗證 help，沒有執行帳號登入，也沒有更改既有模型設定。

**預期證據：**精靈結束後，重新執行 `hermes model` 能看見已設定的 Provider／模型狀態。這仍然只是設定層的證據，下一步才驗證是否能取得回覆。[CLI 命令參考](https://hermes-agent.nousresearch.com/docs/reference/cli-commands)

### 步驟 4：找出設定位置並診斷

```text
hermes config path
hermes config env-path
hermes doctor
```

前兩個命令只需要讀取「位置」，不必把檔案內容印出來。`doctor` 用來檢查環境與設定；逐項閱讀結果，分辨必要項目與暫時用不到的選配功能。沒有 Discord token，不等於普通文字聊天不能用。

**本機實測：**在獨立、未完成帳號設定的臨時 `HERMES_HOME`，路徑查詢皆退出 `0`；`hermes doctor` 也退出 `0`，但仍列出 `.env` 缺少及部分選配項目未設定。這證明不能只用退出碼判斷「一切正常」，更不能把診斷成功當成 Provider 成功回覆。

本章使用不帶修復旗標的 `doctor`。`--fix` 會嘗試修復；`--live` 會做實際網路探測。需要時先讀 `hermes doctor --help`，不要把它們當成同一種檢查。

### 步驟 5：送出第一次訊息

啟動：

```text
hermes
```

若想明確使用傳統 CLI，也可執行 `hermes --cli`。出現輸入區後，輸入以下**練習提示詞**：

```text
請用繁體中文列出三個學習終端機的入門步驟。只回答文字，不呼叫工具。
```

等待回答完成，再確認它有三個步驟、語言正確，而且沒有出現認證或額度錯誤。不要求逐字相同；模型文字會變動。「不要呼叫工具」是任務要求，並非權限隔離機制。

接著輸入 `/help`，確認互動命令可用；在工作已完成後用 `/quit` 離開。新版 CLI 可能連接到背景 Gateway，關閉視窗未必停止已接受的工作，因此不要用強行關閉視窗代替檢查完成狀態。[CLI 介面](https://hermes-agent.nousresearch.com/docs/user-guide/cli)

**預期證據，非本次實測結果：**你看見模型完成回答，並能正常回到 shell。本次寫作沒有發送這筆模型請求；讀者必須在自己的帳號上完成這一關，才算完成本章。

## 常見失敗與恢復

| 症狀 | 排查與恢復 | 重試後的證據 |
| --- | --- | --- |
| `hermes: command not found` | 重新開啟 shell；POSIX 用 `command -v hermes`，PowerShell 用 `Get-Command hermes` 確認位置。POSIX 官方來源安裝預設啟動器目錄為 `~/.local/bin`，應在 PATH 中 | `hermes --version` 能執行 |
| Python／匯入套件錯誤 | 用官方安裝產生的啟動器，不要自行拼出某個 `venv` 路徑。閱讀安裝失敗訊息，依該安裝方式修復 runtime | 版本命令與 `doctor` 能完成 |
| Node.js／前端建置錯誤 | 先保留錯誤摘要，核對目前安裝頁的受管理相依套件流程；若只是圖形介面失敗，先試 `hermes --cli`，再處理第 8 章 | CLI 可聊天；介面問題另行重試 |
| Permission denied | 確認使用原安裝帳號、目標目錄可寫；WSL 優先把 Linux 專案放在 Linux 檔案系統。不要對整份資料放寬成所有人可寫 | 安裝或設定命令可寫入自己的資料目錄 |
| API key／401／額度錯誤 | 回到 `hermes model`，核對 Provider、模型權限與帳號額度；不要將 key 貼到提示詞 | 同一個最小文字提示能取得回覆 |
| OAuth 沒有自動開瀏覽器 | 依終端機顯示的登入流程操作；`hermes model --no-browser` 可用於不自動開瀏覽器的 Nous 登入路線。不要改用停用 TLS 驗證來處理 | 登入完成後的實際聊天成功 |

上述恢復是依官方流程與 help 整理，並非各平台都已重現過的錯誤測試。若仍失敗，留下版本、平台、使用的命令、去除秘密的錯誤摘要，交由第 10 章流程定位。

## 安全提醒與 WSL GUI 邊界

API key、OAuth token、`.env`、`auth.json` 與完整診斷輸出都不應直接提交到 Git。日後修改一般設定時使用 `hermes config set`；秘密優先透過互動式設定精靈輸入，避免出現在命令歷史或截圖中。

WSL2 能執行 CLI，不代表一定能顯示 Desktop 視窗。Linux GUI 需要可用的 WSLg／顯示環境與系統相依套件；WSL1 不支援微軟這條 Linux GUI 路線。沒有 GUI 時仍可在終端機使用 CLI／TUI，或在 WSL 啟動 Dashboard 後用 Windows 瀏覽器存取。完整驗證與替代流程見第 8 章。[Microsoft WSL GUI 文件](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps)

## 練習與完成條件

把第一次提示詞改成「三個整理個人筆記的方法」，再次完成回答。在自己的私人筆記記錄環境、版本、Provider 與模型名稱，以及你從 `doctor` 分辨出的一個選配項目；不要記錄憑證值。

完成本章前，確認以下證據都來自你自己的操作：

- 同一環境能執行 `hermes --version` 與 `hermes --help`。
- 知道設定檔與秘密檔的位置，沒有公開內容。
- 已完成一次實際模型回覆，而不只是精靈或診斷結束。
- 能說明 `doctor` 中仍未設定的項目是否影響這次文字聊天。

## 本章小結

你已建立安裝、設定、實際對話三層驗證方式。第 2 章會沿用這個環境，為對話保留可查詢的 session，練習繼續、匯出與非互動式執行。

## 官方來源與延伸閱讀

- [Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation)：安裝入口、位置、相依套件與診斷。
- [Platform Support](https://hermes-agent.nousresearch.com/docs/getting-started/platform-support)：平台與套件限制。
- [Windows Native](https://hermes-agent.nousresearch.com/docs/user-guide/windows-native)、[Windows WSL2](https://hermes-agent.nousresearch.com/docs/user-guide/windows-wsl-quickstart)：兩種 Windows 路線。
- [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration)、[CLI Commands](https://hermes-agent.nousresearch.com/docs/reference/cli-commands)：設定與命令參考。
- 本次驗證範圍、退出碼與差異紀錄見 `research/codex-ch01-ch02-ch08-sources.md`。
