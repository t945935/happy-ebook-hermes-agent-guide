# 附錄 C：讀者服務與回報問題

## 讀者服務入口

本書的讀者服務 repository：

https://github.com/t945935/happy-ebook-hermes-agent-guide

讀者可以在 GitHub Issues 回報：

- 書中勘誤
- 指令過時或無法執行
- 設定問題
- 範例需要補充
- 建議新增的主題

## 回報前先收集資料

先確認版本：

```bash
hermes --version
```

再視問題執行：

```bash
hermes doctor
hermes config check
hermes auth status
hermes logs errors
```

## Issue 應包含什麼

請提供：

1. 書中的章節或頁碼。
2. Hermes Agent 版本。
3. 作業系統與環境，例如 WSL2、Windows、macOS 或 Linux。
4. 實際執行的命令。
5. 錯誤訊息和重現步驟。
6. 你原本預期的結果，以及實際結果。

貼出結果前，請移除 API key、OAuth token、bot token、密碼、私人路徑和個人資料。

## 內容修正的處理方式

若問題涉及 Hermes 的現行命令、模型或平台能力，應先以官方文件和目前安裝版本核對，再決定修正書稿或補充說明。不要只因某個讀者環境失敗，就宣稱功能在所有平台都失效。

本 repository 是讀者服務與補充資料入口，不等於本書未出版書稿、作者工作區或商店上架頁。外部服務可能變更，讀者仍應以 Hermes 官方文件及實際錯誤訊息為準。

## 回報範例

```text
標題：第 1 章的 hermes doctor 結果與說明不同

章節：第 1 章，〈安裝後檢查〉
Hermes 版本：請填寫 hermes --version 結果
環境：Windows 11、WSL2 Ubuntu
命令：hermes doctor
預期結果：應該看到設定檔檢查通過
實際結果：請貼上已移除秘密的錯誤訊息
重現步驟：
1. 安裝 Hermes
2. 執行 hermes doctor
```
