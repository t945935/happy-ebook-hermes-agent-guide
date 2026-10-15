# 第 3 章：設定模型與 API Provider

> **本章目標**  
> 讓讀者能選擇 provider、登入 OAuth、設定 API key provider、配置自訂端點，並驗證模型實際可用。完成後讀者能完成一次有工具呼叫的實際聊天，且能說明目前使用的 provider 與模型。

> **適用讀者與前提**  
> - 已完成第 1 章安裝，`hermes --version` 正常顯示  
> - 具備終端機基本操作、環境變數概念  
> - 擁有至少一組可用的模型 Provider 帳號（或準備使用 Nous Portal）

---

## 3.1 核心概念

### 3.1.1 Provider、Model、Credential 的關係

| 層級 | 說明 | 設定位置 |
|------|------|----------|
| **Provider** | 推理服務商（OpenRouter、Anthropic、Nous Portal、OpenAI Codex、GitHub Copilot、Custom 等） | `config.yaml` 的 `model.provider`、`.env` 或 auth store |
| **Model** | 具體模型名稱（如 `anthropic/claude-sonnet-4`、`gpt-5.4`） | `config.yaml` 的 `model.default` |
| **Credential** | API key、OAuth token、device code 流程產生的憑證 | `~/.hermes/.env`、 `~/.hermes/auth.json`、環境變數 |

> **關鍵區別**  
> - `hermes model`：在終端機執行，**可新增 provider、跑 OAuth、輸入 API key、設定 custom endpoint**  
> - `/model`：在聊天 session 內，**只能切換已設定的 provider/model，不可新增**

### 3.1.2 設定優先順序（高 → 低）

1. CLI 參數 `--provider`、`--model`、`--base-url`
2. `config.yaml` 的 `model.provider` / `model.default` / `model.base_url`
3. 環境變數（`OPENROUTER_API_KEY`、`ANTHROPIC_API_KEY` 等）
4. Provider-specific defaults（內建 fallback model 列表）

> **注意**：舊版使用的 `LLM_MODEL`、`.env` 內的 `OPENAI_BASE_URL` 已棄用或僅限特定 provider，請以 `config.yaml` 為單一真實來源。

---

## 3.2 實作情境

| 情境 | 適用指令 |
|------|----------|
| 全新安裝，想要最快上手 | `hermes setup --portal` |
| 已安裝，想互動式選 provider/model | `hermes model` |
| 已有 API key，想手動加入 | `hermes auth add <provider> --api-key <key>` |
| 想用 OAuth 登入 Anthropic/Codex/Copilot | `hermes auth add <provider> --type oauth` |
| 想設定自訂 OpenAI-compatible endpoint | `hermes model` → 選 Custom endpoint |
| 想建立 fallback 鏈 | `hermes fallback` |
| 想查看目前實際生效的 provider/model | `hermes config get model --json`、`hermes status` |

---

## 3.3 步驟與指令

### 3.3.1 情境 A：首次安裝 → Nous Portal 一鍵設定（推薦新手）

```bash
hermes setup --portal
```

**流程**：
1. 開啟瀏覽器進行 Nous Portal OAuth 登入
2. 自動將 `model.provider` 設為 `nous`，挑選預設模型
3. 同步啟用 Tool Gateway（web search、image generation、TTS、cloud browser 等）
4. 寫入 `config.yaml` 並建立 `~/.hermes/.env` 必要變數

**預期結果（示意輸出）**：
```text
✓ Logged in to Nous Portal
✓ Provider set to: nous
✓ Default model: anthropic/claude-sonnet-4
✓ Tool Gateway enabled
✓ Configuration saved to ~/.hermes/config.yaml
```

**驗證**：
```bash
hermes chat -q "你好，請用一句話介紹你自己"
# 應收到模型回覆，且 `hermes status` 顯示 provider: nous
```

---

### 3.3.2 情境 B：互動式選擇 Provider 與 Model

```bash
hermes model
```

**流程**（互動式選單，實測畫面略）：
1. 列出所有**已設定憑證**的 provider（左欄）與推薦模型（右欄）
2. 選擇 provider → 如未設定憑證，提示 OAuth 或輸入 API key
3. 選擇模型 → 寫入 `model.provider`、`model.default`
4. 接著詢問 **Reasoning effort**（minimal/low/medium/high/ultra/disable/skip），寫入 `agent.reasoning_effort`

**預期結果**：
- `config.yaml` 的 `model:` 區塊從空字串 `""` 升級為 mapping：
```yaml
model:
  provider: openrouter
  default: anthropic/claude-sonnet-4
  base_url: ""          # 非 custom 時為空
  api_mode: chat_completions
agent:
  reasoning_effort: medium
```

**驗證**：
```bash
hermes config get model --json
# {"provider":"openrouter","default":"anthropic/claude-sonnet-4",...}
hermes chat -q "測試模型切換"
```

---

### 3.3.3 情境 C：以 API Key 加入 Provider（以 OpenRouter 為例）

```bash
# 方式 1：互動式（會提示輸入 key）
hermes auth add openrouter --type api_key

# 方式 2：非互動式（適合腳本）
hermes auth add openrouter --api-key sk-or-v1-xxxxxxxxxxxx

# 方式 3：環境變數（僅建議臨時測試）
export OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxx
hermes chat --provider openrouter --model anthropic/claude-sonnet-4 -q "測試"
```

> **安全提醒**：API key 寫入 `~/.hermes/.env` 後，**請勿**將該檔案提交至 Git。生產環境建議使用秘密管理工具或 `hermes auth add` 寫入 auth store。

**驗證**：
```bash
hermes auth list openrouter
# 顯示索引、來源、狀態（valid/cooldown/quarantined）
hermes chat --provider openrouter -q "測試 OpenRouter"
```

---

### 3.3.4 情境 D：OAuth 登入（Anthropic、OpenAI Codex、GitHub Copilot、xAI Grok、MiniMax、Qwen）

```bash
# Anthropic（需 Claude Max + extra usage credits）
hermes auth add anthropic --type oauth

# OpenAI Codex（ChatGPT 或 Codex Subscription，device code 預設）
hermes auth add openai-codex --type oauth
# 組織禁用 device code 時改用瀏覽器 PKCE（固定 localhost:1455）
hermes auth add openai-codex --browser

# GitHub Copilot
hermes auth add copilot --type oauth
# 或設定環境變數 COPILOT_GITHUB_TOKEN / GH_TOKEN / GITHUB_TOKEN

# xAI Grok OAuth（SuperGrok/Premium+）
hermes auth add xai-oauth --type oauth

# MiniMax / Qwen OAuth
hermes auth add minimax --type oauth
hermes auth add qwen --type oauth
```

**OAuth 流程說明**：
- Device code：終端機顯示 URL + code，於瀏覽器完成授權
- Browser PKCE：啟動本地 `localhost:1455` 回呼，**SSH 需 tunnel** `ssh -N -L 1455:127.0.0.1:1455 user@host`
- 憑證存放：`~/.hermes/auth.json`，自動 refresh、失效隔離（quarantine）

**驗證**：
```bash
hermes auth status anthropic
# 顯示 credential 狀態、expires_at、cooldown、quarantine
hermes chat --provider anthropic -q "測試 Anthropic OAuth"
```

---

### 3.3.5 情境 E：Custom Endpoint（自架 Ollama、vLLM、SGLang、OpenAI-compatible API）

```bash
hermes model
# 選單選 "Custom endpoint (self-hosted / VLLM / etc.)"
# 依序輸入：
#   API base URL:  http://localhost:11434/v1   (Ollama 範例)
#   API key:       (可留空，若端點無需 key)
#   Model name:    qwen2.5:7b
```

**手動 config.yaml 等價寫法**：
```yaml
model:
  provider: custom
  base_url: "http://localhost:11434/v1"
  default: "qwen2.5:7b"
  api_mode: chat_completions
# api_key 可寫在 ~/.hermes/.env 的 CUSTOM_API_KEY=xxx，或留空
```

> **重要**：`base_url` 優先於 `provider`。Hermes 使用配置的 `api_key` 驗證，**不會**拿 `OPENROUTER_API_KEY` 去打 custom endpoint。

**驗證**：
```bash
hermes chat --provider custom -q "測試本地模型"
# 或啟動 session 後 /model custom:qwen2.5:7b
```

---

### 3.3.6 情境 F：建立 Fallback Provider 鏈

```bash
# 互動式管理（同 provider picker UI）
hermes fallback

# 非互動式新增
hermes fallback add openrouter anthropic/claude-sonnet-4
hermes fallback add anthropic claude-sonnet-4-6
hermes fallback list
hermes fallback remove 1
hermes fallback clear
```

**config.yaml 產出**：
```yaml
fallback_providers:
  - provider: openrouter
    model: anthropic/claude-sonnet-4
  - provider: anthropic
    model: claude-sonnet-4-6
```

**觸發條件（官方文件）**：
- Rate limit (HTTP 429) —— 重試耗盡後
- Server error (500/502/503) —— 重試耗盡後
- Auth failure (401/403) —— 立即
- Not found (404) —— 立即
- Invalid response（空回應、router timeout 訊息）—— 重試後

**支援場景**：CLI session、Gateway、Desktop/TUI、Subagent delegation、Cron jobs、Auxiliary tasks

**驗證（示意）**：
```bash
# 模擬 primary 失敗：暫時移除 primary API key 或設定錯誤 model
hermes chat -q "這個請求應該觸發 fallback"
# 觀察日誌：`fallback activated: openrouter -> anthropic`
```

---

### 3.3.7 情境 G：Session 內切換 Model（`/model` slash command）

```text
/model                    # 顯示目前模型與可用選項
/model claude-sonnet-4    # 切換模型（自動偵測 provider）
/model zai:glm-5          # 明確指定 provider:model
/model custom:qwen-2.5    # 使用 custom endpoint 模型
/model --global gpt-5.4   # 同步寫入 config.yaml（持久化）
/model --once gpt-5.4     # 單輪生效，下一輪自動還原
```

> **限制**：`/model` **無法**新增 provider、跑 OAuth、輸入 API key。需先在終端機執行 `hermes model` 完成設定。

---

## 3.4 預期結果（標示示意或實測）

| 操作 | 可觀察證據 |
|------|------------|
| `hermes setup --portal` 成功 | `hermes status` 顯示 `provider: nous`、`model: anthropic/claude-sonnet-4`、`gateway: enabled` |
| `hermes auth add openrouter --api-key ...` | `hermes auth list openrouter` 顯示索引 0、source=api_key、status=valid |
| `hermes model` 選 custom endpoint | `hermes config get model --json` 顯示 `provider: custom`、`base_url` 正確 |
| `hermes fallback add ...` | `hermes fallback list` 顯示鏈順序；模擬 429 觸發切換 |
| `/model --global ...` | 新 session 啟動時預設即為該模型 |

> **註**：上述為文獻預期結果，**實測輸出請以當下環境為準**，並於章節標註實測版本與平台。

---

## 3.5 常見失敗與恢復

| 症狀 | 可能原因 | 恢復步驟 |
|------|----------|----------|
| `hermes chat` 回覆空白/斷裂 | Provider auth 錯誤、model 名稱錯誤 | 1. `hermes model` 重新選擇 2. `hermes auth status <provider>` 檢查憑證 3. `hermes doctor` 診斷 |
| Custom endpoint "能連但回垃圾" | base_url 錯誤、model 名稱不符、非 OpenAI-compatible | 1. 先用 `curl` 或其他 client 驗證端點 2. 確認 `/v1/models` 回傳 model list 3. `hermes model` 重新輸入正確資訊 |
| OAuth 登入卡在 localhost | SSH 無 tunnel、port 1455 被佔用 | 1. `ssh -N -L 1455:127.0.0.1:1455 user@host` 2. 或改用 device code `hermes auth add ...`（不加 `--browser`） |
| Fallback 不觸發 | `fallback_providers` 空、或 primary 未真正失敗（如 200 但內容異常） | 1. `hermes fallback list` 確認鏈存在 2. `hermes logs --level debug` 觀察 fallback 判定邏輯 |
| `/model` 找不到想要的 provider | 該 provider 尚未在 `hermes model` 設定過 | 退出 session → `hermes model` 設定 → 重新進入 session |

---

## 3.6 安全提醒

- **API key、OAuth token、device code 絕不寫入章節範例實值**  
- `~/.hermes/.env`、`~/.hermes/auth.json`、**不可**提交至版控  
- 使用 `hermes config set` 修改設定，避免手動編輯 `config.yaml` 導致格式錯誤  
- Custom endpoint 的 `key_cmd` 若使用，**務必**確保指令輸出僅含 key、無副作用  
- Fallback 鏈會自動切換到不同 provider，**可能產生不同帳單**，請確認每個 fallback 的計費方式  
- `--yolo` 會跳過 tool approval，**不可**在生產或共用環境使用

---

## 3.7 練習

1. **基礎**：執行 `hermes setup --portal`，完成首次聊天並用 `hermes status` 確認 provider
2. **進階**：用 `hermes auth add openrouter --api-key $YOUR_KEY` 加入 OpenRouter，切換模型並驗證
3. **挑戰**：設定一個 custom endpoint（如本地 Ollama），建立 fallback 鏈 `custom → openrouter → anthropic`，模擬 primary 失敗觀察切換

---

## 3.8 完成條件

- [ ] 能執行 `hermes model` 並完成一個 provider 的設定（OAuth 或 API key 或 custom）
- [ ] 能用 `hermes auth list/status` 說明目前憑證狀態
- [ ] 能建立 fallback 鏈並解釋觸發條件
- [ ] 能在 session 內用 `/model` 切換模型，並區分 `--global`/`--once` 差異
- [ ] 能完成一次有工具呼叫的實際聊天，並說明目前使用的 provider 與模型

---

## 3.9 本章小結

本章涵蓋 Hermes 模型設定的完整路徑：從 `hermes setup --portal` 的零配置起步，到 `hermes model` 的互動式選擇、`hermes auth` 的憑證管理、custom endpoint 的手動配置，以及 `hermes fallback` 的高可用鏈。關鍵原則：**先讓單一 provider 穩定可用，再加入 fallback 與多 provider 切換**。所有敏感資訊皆透過 `hermes auth` 或 `hermes config set` 寫入，避免手動編輯設定檔。

---

## 3.10 官方來源與延伸閱讀

- CLI 指令參考：https://hermes-agent.nousresearch.com/docs/reference/cli-commands
- Provider 整合指南：https://hermes-agent.nousresearch.com/docs/integrations/providers
- Fallback Providers：https://hermes-agent.nousresearch.com/docs/user-guide/features/fallback-providers
- 模型設定指南：https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models
- 快速入門：https://hermes-agent.nousresearch.com/docs/getting-started/quickstart
- 新增 Provider 開發指南：https://hermes-agent.nousresearch.com/docs/developer-guide/adding-providers
- Provider 執行期解析：https://hermes-agent.nousresearch.com/docs/developer-guide/provider-runtime