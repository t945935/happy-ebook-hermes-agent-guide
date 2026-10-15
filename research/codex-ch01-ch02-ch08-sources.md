# Codex 第 1、2、8 章來源與驗證紀錄

## 範圍與證據分級

- 核對日期：2026-10-15。
- 指派範圍：`manuscript/ch01-installation.md`、`manuscript/ch02-cli.md`、`manuscript/ch08-surfaces.md` 與本檔；未修改共用狀態。
- 本機 `hermes --version`：`Hermes Agent v0.21.1 (2026.9.7) · upstream 05d705dd`。
- 本機來源 checkout 的 `git rev-parse HEAD`：`05d705dd695d1084388529124dc2ffe5ce919e89`。這是本機參照版本，未聲稱為當日最新 release。
- 環境：Linux／WSL；Python 版本由 Hermes 輸出為 `3.11.16`。只記錄平台與版本，不收錄使用者名稱、工作站絕對路徑、憑證或私有日誌。
- 「官方文件」指本次透過網頁工具讀取的官方站；「本機 help」只證明命令介面；「隔離實測」指臨時 `HERMES_HOME` 中實際執行的有限管理命令；「文件流程」不等於端到端驗證。
- 網頁是滾動更新內容，本機隨附文件與公開網站有差異；不能用網站內容替本機未執行的功能背書。

本檔是使用者指定交付的研究摘要，不含原始 runtime dump。所有書稿與研究檔只做本機提交，沒有執行推送或發布。

## 已讀交接資料

開工先讀 `AGENTS.md`、`notes/writing-plan.md`、`notes/agent-assignments.md`、`notes/chapter-status.yaml`；初始 `git status --short` 為空。四個目標檔案原先不存在，因此沒有覆寫既有章節。分工文件另列主 checkout 位置，本次依使用者提供的工作環境在指派 worktree 操作。

## 官方來源清單

以下 URL 均於核對日期透過網頁工具開啟或由官方頁連結進入。網頁工具不提供 shell 退出碼；不能把頁面成功載入記成 CLI exit `0`。

| 編號 | 來源 | 使用範圍 |
| --- | --- | --- |
| S01 | [Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation) | 官方 Bash／PowerShell 安裝入口、安裝與資料目錄分離、相依套件、設定命令、診斷 |
| S02 | [Platform Support](https://hermes-agent.nousresearch.com/docs/getting-started/platform-support) | 平台與架構範圍、套件限制、非支援的安裝方式 |
| S03 | [Windows Native](https://hermes-agent.nousresearch.com/docs/user-guide/windows-native) | PowerShell 路線、Windows 資料目錄、與 WSL 共存 |
| S04 | [Windows WSL2](https://hermes-agent.nousresearch.com/docs/user-guide/windows-wsl-quickstart) | WSL 安裝與版本確認、檔案系統、Windows↔WSL 網路邊界 |
| S05 | [CLI Interface](https://hermes-agent.nousresearch.com/docs/user-guide/cli) | 啟動與查詢、模型與 toolset、Gateway 型 CLI 的行為差異 |
| S06 | [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) | setup、model、doctor、sessions、logs、config、Dashboard 的交叉參照 |
| S07 | [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) | `config.yaml`／`.env`／`auth.json` 分工、用 `config set` 操作設定 |
| S08 | [Sessions](https://hermes-agent.nousresearch.com/docs/user-guide/sessions) | 儲存、ID、續接、工作目錄與來源差異 |
| S09 | [Slash Commands](https://hermes-agent.nousresearch.com/docs/reference/slash-commands) | `/help`、`/model`、`/quit` 等命令；仍須核對當前介面 |
| S10 | [TUI](https://hermes-agent.nousresearch.com/docs/user-guide/tui) | `--tui`／`--cli`、`display.interface`、session/model/agents/usage 面板 |
| S11 | [Web Dashboard](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard) | loopback、port、Chat 的 PTY 限制、認證、遠端連線 |
| S12 | [Desktop](https://hermes-agent.nousresearch.com/docs/user-guide/desktop) | 原生介面、共用狀態、本機與遠端 backend |
| S13 | [Microsoft：Run Linux GUI apps with WSL](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps) | WSL2／Windows／顯示驅動前提；GUI 並非完整 Linux 桌面保證 |
| S14 | [OpenSSH ssh(1)](https://man.openbsd.org/ssh.1) | `-N`、`-L` 與 loopback local forwarding 的範例語法 |

搜尋結果曾包含非官方鏡像與近似拼字網域，未用於正文證據。初次嘗試的 `/docs/user-guide/windows` 與 `/docs/getting-started/platforms` 不能存取，之後改從官方頁連結取得 S04 與 S02，不在正文保留錯誤 URL。

## 本機公開原始碼與隨附文件

以下讀碼以本機安裝 checkout 為準，不宣稱遠端 `main` 與該 checkout 相同：

- [`hermes_cli/main.py`](https://github.com/NousResearch/hermes-agent/blob/05d705dd695d1084388529124dc2ffe5ce919e89/hermes_cli/main.py)：CLI 入口、oneshot 與介面選擇線索。
- [`hermes_cli/oneshot.py`](https://github.com/NousResearch/hermes-agent/blob/05d705dd695d1084388529124dc2ffe5ce919e89/hermes_cli/oneshot.py)：`-z` 設定 `HERMES_YOLO_MODE=1` 與 `HERMES_ACCEPT_HOOKS=1`；指定 Provider 卻沒有明確模型時的拒絕分支。
- [`hermes_cli/main_desktop.py`](https://github.com/NousResearch/hermes-agent/blob/05d705dd695d1084388529124dc2ffe5ce919e89/hermes_cli/main_desktop.py)：有 WSLg／D3D12 相關處理；不能據此推論本機 GUI 已成功。
- 同一 checkout 的 `website/docs/user-guide/tui.md`、`desktop.md`、`features/web-dashboard.md`、`windows-wsl-quickstart.md`、`configuration.md`、`cli.md` 與 `website/docs/reference/slash-commands.md`：以檔案讀取核對版本差異與操作語意。

## 實際執行命令與退出結果

### 版本與 help

下列各命令實際執行，**每個退出碼都是 `0`**。help 不代表執行過其功能；例如 `desktop --help` 不會證明 Desktop 能開啟。

```text
command -v hermes
hermes --version
hermes --help
hermes chat --help
hermes setup --help
hermes model --help
hermes doctor --help
hermes sessions --help
hermes sessions list --help
hermes sessions export --help
hermes sessions rename --help
hermes logs --help
hermes config --help
hermes config set --help
hermes config get --help
hermes config check --help
hermes dashboard --help
hermes desktop --help
```

批次 help 使用 `python3` 的 `subprocess.run`，逐一收集各子程序 `returncode`，不以外層 Python 退出碼替代子命令結果。

### 隔離設定與空白歷史測試

以 Python `tempfile.mkdtemp` 建立臨時資料目錄，在子程序環境指定 `HERMES_HOME`，沒有改寫使用者原本的設定。`HERMES_HOME` 隔離資料位置不等於完整作業系統或環境變數 sandbox；本次只用於下表的有限測試。

| 實際命令 | Exit | 可公開的觀察 |
| --- | --- | --- |
| `hermes config set display.interface tui` | 0 | 設定寫入成功 |
| `hermes config get display.interface` | 0 | 回傳 `tui` |
| `hermes config set display.interface cli` | 0 | 設定寫入成功 |
| `hermes config get display.interface` | 0 | 回傳 `cli` |
| `hermes config path` | 0 | 指向隔離資料目錄的 `config.yaml` |
| `hermes config env-path` | 0 | 指向隔離資料目錄的 `.env` |
| `hermes config check` | 0 | 列出設定版本更新需求及選配項目；未據此聲稱模型可用 |
| `hermes sessions list --limit 5` | 0 | `No sessions found.` |
| `hermes doctor` | 0 | Python 與 Node 檢查列為可用，仍有 `.env` 缺少及選配功能未設定；沒有執行 `--fix` 或 `--live` |

`doctor` 使用另一個空白臨時資料目錄，設定 35 秒子程序 timeout；命令在限制內結束，沒有發生 timeout。只保留不含秘密的摘要，不納入原始診斷輸出。讀者完成安裝的證據仍須包含實際模型回覆。

### 平台、研究與編輯命令

| 命令或操作 | 結果 |
| --- | --- |
| `pwd`、`git status --short`、`rg --files` 與 `cat` 交接資料 | 初始命令退出 `0`；初始工作樹乾淨 |
| `git -C HERMES_SOURCE rev-parse HEAD`（`HERMES_SOURCE` 為匿名化來源位置） | 退出 `0`，commit 如本檔開頭 |
| Python `platform.release()` 判斷核心是否含 `microsoft` | `True`；檢查腳本退出 `0` |
| Python 檢查 `DISPLAY`／`WAYLAND_DISPLAY` 是否有值 | 都為 `True`；沒有輸出原值，也沒有將其當成 GUI 成功證據 |
| `python` 執行第一版 help 批次腳本 | 外層退出 `127`，shell 找不到 `python`；改用 `python3` 後成功 |
| `curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/website/docs/user-guide/tui.md`（原命令另帶臨時輸出檔） | 退出 `6`，命令執行環境無法解析主機；改用網頁工具讀官方站 |
| 初次 `rg` 查找猜測的 `hermes_cli/desktop.py`、`windows.md`、`chat_gateway.py` | 個別查找報不存在；相關批次有退出 `2`，後以檔案列舉找到 `main_desktop.py`、`windows-wsl-quickstart.md`；未引用不存在的檔案 |
| `rg --files manuscript research -g AGENTS.md` | 建檔前兩個目錄不存在，退出 `2`；沒有下層規則可讀 |
| 修正路徑後用 `rg`、`sed`、Python `Path.read_text()` 讀本機文件與原始碼 | 完成相關段落讀取；後續批次退出 `0` |

上表記錄會影響驗證結論的失敗，避免把命令不可用或網路錯誤省略成「已全部驗證」。未把作者工作站的具體位置寫入研究檔。

## 重要差異與正文處理

| 差異／陷阱 | 證據 | 正文處理 |
| --- | --- | --- |
| 本機版本與網站內容不完全相同 | `--version` 與 S01、S05 | 明列核對日與實測版本，不稱為最新版 |
| 官方安裝頁現採受管理 runtime，本機仍顯示 Python 3.11.16 | S01 與本機版本輸出 | 不把本機 Python 當成新安裝需求；不固定舊版 Node 安裝配方 |
| `chat -q` 的簡短文件說明與 TTY 行為有落差 | S05 與 `chat --help` | 一次後退出明寫 `chat --oneshot -q`；區分頂層 `--oneshot PROMPT` |
| 頂層 `-z` 會略過 approval | `--help`、`oneshot.py` | 在腳本範例旁說明工具、規則與 approval 邊界 |
| `doctor` 有缺少項目仍退出 `0` | 隔離實測 | 要求閱讀檢查內容，不能只靠 exit 判斷成功 |
| 新版 CLI 頁說明 Gateway 型 CLI 的 slash 子集，其他文件仍描述完整 registry | S05、S09、S10 | 通用流程只依賴 `/help`／`/quit`；歷史管理用 shell；完整面板放第 8 章 TUI |
| `latest`／continue 有工作目錄與終端機範圍描述 | S08 與本機 help | 主練習使用明確 session ID，不保證所有介面都選全域最新一筆 |
| Dashboard Chat 目前不需額外 `--tui` | S11 與 Dashboard help | 不教不存在的 `dashboard --tui` |
| Dashboard 非 loopback 需要認證，`--insecure` 是 no-op | S11 與 Dashboard help | 主流程保留 loopback；遠端以 SSH tunnel 範例示範 |
| `dashboard --stop` 範圍可能涵蓋多個 web server | Dashboard help | 停止前查狀態並確認都是要停止的工作 |
| 原生 Windows 管理頁與 PTY Chat 支援不同 | S04、S11 | 明列 Chat 的 POSIX／WSL 路線，不概括成 Windows 不支援 Hermes |
| Desktop 與 WSLg 是不同驗證層次 | Desktop help、S12、S13、本機變數存在檢查 | GUI 成功未驗證；提供 TUI、Windows 瀏覽器及原生 Windows Desktop 替代路線 |
| macOS Intel 說法在安裝頁與平台表不完全一致 | S01、S02 | 主線限 Apple Silicon；Intel 讀者回查平台表，不提供無條件支援承諾 |
| 舊版 Dashboard 文件使用額外相依套件安裝配方，新站已有核心依賴變更 | 本機隨附 S11 對應文件與當前 S11 | 不提供跨版本通用 `pip install` 修復命令，要求依安裝方式處理 |

## 尚未驗證的讀者流程

- Linux／macOS／WSL2 的全新安裝，以及 Windows PowerShell／Desktop 套件安裝。
- `hermes setup`、`hermes model`、Nous Portal OAuth 與其他 Provider 認證的實際互動。
- 任一真實模型回覆、工具執行、費用或 Provider 可用性；提示詞均為練習示例。
- session 建立、改名、跨介面續接與內容匯出的端到端結果；只驗證 help 與空資料查詢。
- `chat --oneshot -q`、`--query-file`、`-z` 腳本的真實推論與輸出；`-z` approval 說法來自 help 與讀碼。
- TUI 面板、live session 切換、Node 建置與鍵盤互動；只實測 `display.interface` 設定的寫入／讀回。
- Dashboard 啟動、port、status／stop 的實際服務生命週期、browser Chat、認證及 WebSocket。
- SSH tunnel、Windows→WSL localhost 轉送與防火牆差異。
- Desktop 下載／建置／啟動、WSLg 視窗、GPU、剪貼簿與跨環境 backend 連線。

以上均在正文標成文件流程或未實測；沒有將示意輸出宣稱為實測。未有無來源的功能推測用來補足缺項。

## 交付與下一步

三章各包含目標、前提、工作情境、操作、預期證據、恢復、安全提醒、練習、完成條件、小結與來源。正文不依賴其他作者章節完成才能重做核心練習，跨章引用使用既定章號。

交付檢查與 Git 限制：

- 已讀回四個檔案，檢查章節必要項目、程式碼 fence 配對、檔尾換行、行尾空白與私人絕對路徑；最終檢查通過。第一輪因第 2 章安全段落標題未含模板名稱而退出 `1`，已補明「安全提醒」後重查。
- 原 worktree 的 `git diff --check` 退出 `0`；因四檔尚為 untracked，此結果本身不足以驗證新檔案。
- 原 worktree 的 `git add --` 四個指定檔案退出 `128`：Git 中繼資料所在位置為唯讀，不能建立 `index.lock`。沒有要求提升權限，也沒有修改原 Git 目錄權限。
- 在允許寫入的臨時目錄執行 `git clone --no-hardlinks --no-checkout`，以原 worktree 的基底 `0f5f79e9acfe6f28e70737085c9e19cdcd6d58c3` 建立隔離 checkout，複製相同四檔並暫存。clone、checkout、add 均退出 `0`；隔離 checkout 的 `git diff --check` 與 `git diff --cached --check` 均退出 `0`，後者實際涵蓋新增檔案。
- 曾用 `git diff --no-index --check /dev/null FILE` 檢查新檔；它回傳 `1` 而沒有診斷文字，不當成正式通過紀錄，改採上面的 staged diff 檢查。
- commit 與可匯入的 Git bundle 在隔離 checkout 產生；實際 commit ID、bundle 位置與驗證結果由交接訊息提供。原 worktree 保留四個工作檔，原分支未提交這批變更。

後續由整合者核對全書術語與版本基準，並安排有測試帳號、可用網路與圖形環境的端到端驗收。優先補做「初始聊天 → session 匯出 → TUI／Dashboard 續接」，再驗證 Windows 原生與 WSL GUI 差異。以上未完成前，不應把三章標成已通過所有跨平台實測。
