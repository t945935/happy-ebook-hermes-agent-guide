# 啟動多 Agent 寫作實作

工作目錄：`/home/j5/happy-ebook-hermes-agent-guide`

## 0. 目前環境檢查結果

已確認可直接找到：

- `pi`: `/home/j5/.local/bin/pi`
- `opencode`: `/home/j5/.local/bin/opencode`
- `codex`: `/home/j5/.local/bin/codex`
- `hermes`: `/home/j5/.local/bin/hermes`
- `antigravity`: 尚未安裝或不在 PATH

## 1. 建立隔離 Worktree

不要讓多個 Agent 同時修改同一個工作目錄。執行：

```bash
cd /home/j5/happy-ebook-hermes-agent-guide
mkdir -p /home/j5/agent-worktrees

git worktree add -b agent/codex /home/j5/agent-worktrees/codex main
git worktree add -b agent/opencode /home/j5/agent-worktrees/opencode main
git worktree add -b agent/pi /home/j5/agent-worktrees/pi main
# Antigravity 可用後再建立：
# git worktree add -b agent/antigravity /home/j5/agent-worktrees/antigravity main
```

## 2. 啟動 Codex

```bash
codex exec --sandbox workspace-write \
  -C /home/j5/agent-worktrees/codex \
  "讀取 AGENTS.md、notes/writing-plan.md、notes/agent-assignments.md。你負責第 1～2 章。撰寫 manuscript/ch01-installation.md、manuscript/ch02-cli.md 和 research/codex-ch01-ch02-sources.md。只修改自己的章節與研究檔，不修改共用狀態。完成後執行 git diff --check，提交變更，並回報檔案、來源、實測命令、未驗證內容和 commit。"
```

## 3. 啟動 OpenCode

```bash
opencode run --dir /home/j5/agent-worktrees/opencode \
  "讀取 AGENTS.md、notes/writing-plan.md、notes/agent-assignments.md。你負責第 3～4 章。撰寫 manuscript/ch03-model-provider.md、manuscript/ch04-skills.md 和 research/opencode-ch03-ch04-sources.md。只修改自己的章節與研究檔，不修改共用狀態。完成後執行 git diff --check，提交變更，並回報檔案、來源、實測命令、未驗證內容和 commit。"
```

## 4. 啟動 Pi

```bash
pi -p \
  --session-dir /home/j5/agent-worktrees/pi/.pi-sessions \
  --append-system-prompt /home/j5/agent-worktrees/pi/AGENTS.md \
  -- "讀取 notes/writing-plan.md 和 notes/agent-assignments.md。你負責第 5～7 章。撰寫 manuscript/ch05-delegation.md、manuscript/ch06-messaging.md、manuscript/ch07-cron.md 和 research/pi-ch05-ch07-sources.md。只修改自己的章節與研究檔，不修改共用狀態。完成後執行 git diff --check，提交變更，並回報檔案、來源、實測命令、未驗證內容和 commit。"
```

## 5. Antigravity

目前本機找不到 `antigravity` 指令。先在其可用的環境中開啟同一個 Repository，建立獨立分支：

```bash
git worktree add -b agent/antigravity /home/j5/agent-worktrees/antigravity main
```

交給 Antigravity：

```text
讀取 AGENTS.md、notes/writing-plan.md、notes/agent-assignments.md。
你負責第 8～9 章：Desktop／Dashboard／TUI、MCP／Webhook／Plugin。
只修改自己的 manuscript/ch08-surfaces.md、manuscript/ch09-integrations.md 和 research/antigravity-ch08-ch09-sources.md。
完成後回報檔案、來源、實測命令、未驗證內容和 commit。
```

## 6. 收集 Agent 結果

每個 Agent 完成後，確認其分支狀態：

```bash
for w in codex opencode pi antigravity; do
  if test -d "/home/j5/agent-worktrees/$w"; then
    printf '\n--- %s ---\n' "$w"
    git -C "/home/j5/agent-worktrees/$w" status --short --branch
    git -C "/home/j5/agent-worktrees/$w" log -1 --oneline
  fi
done
```

## 7. 由 Hermes 整合

先不要直接覆蓋主分支。逐一檢查 Agent 的 commit 和檔案內容，再在主工作目錄整合：

```bash
cd /home/j5/happy-ebook-hermes-agent-guide
git status --short --branch
git log --oneline --all --decorate -15
```

確認內容後合併分支：

```bash
git merge --no-ff agent/codex -m "docs: add installation and CLI chapters"
git merge --no-ff agent/opencode -m "docs: add provider and skills chapters"
git merge --no-ff agent/pi -m "docs: add delegation messaging and cron chapters"
git merge --no-ff agent/antigravity -m "docs: add surfaces and integration chapters"
```

若某個 Agent 尚未提交，先要求它提交；不要直接把未審查內容拷貝進主分支。

## 8. Hermes 整合檢查

```bash
cd /home/j5/happy-ebook-hermes-agent-guide
git diff --check
python3 - <<'PY'
from pathlib import Path
import yaml
p = Path('notes/chapter-status.yaml')
data = yaml.safe_load(p.read_text())
for item in data['chapters']:
    draft = Path(item['draft'])
    if item['status'] != 'planned' and not draft.exists():
        raise SystemExit(f"Missing draft: {draft}")
print('Chapter status YAML valid')
PY
```

Hermes 最後才更新 `notes/chapter-status.yaml`，並進行全書交叉引用、命令、來源、安全和格式審查。

## 9. 重要限制

- Agent 回報完成不等於內容已驗證。
- `git merge` 前必須讀回章節和研究檔。
- 不把 API key、OAuth token、bot token 或私有日誌提交到 Git。
- `antigravity` 在目前 WSL PATH 中不存在，不能假設它已經能執行。
