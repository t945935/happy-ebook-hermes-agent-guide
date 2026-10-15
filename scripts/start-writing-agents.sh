#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREE_ROOT="${HERMES_AGENT_WORKTREES:-/home/j5/agent-worktrees}"
RUN_ROOT="${HERMES_AGENT_RUNS:-$REPO_DIR/.agent-runs}"
ACTION="${1:-start}"

log() { printf '[writing-agents] %s\n' "$*"; }
die() { printf '[writing-agents] ERROR: %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "找不到指令：$1"
}

agent_prompt() {
  case "$1" in
    codex)
      printf '%s' '讀取 AGENTS.md、notes/writing-plan.md、notes/agent-assignments.md。你負責第 1～2 章。撰寫 manuscript/ch01-installation.md、manuscript/ch02-cli.md 和 research/codex-ch01-ch02-sources.md。只修改自己的章節與研究檔，不修改共用狀態。使用目前官方文件和實際 CLI help 驗證命令。完成後執行 git diff --check，提交變更，並回報檔案、來源、實測命令、未驗證內容和 commit。';;
    opencode)
      printf '%s' '讀取 AGENTS.md、notes/writing-plan.md、notes/agent-assignments.md。你負責第 3～4 章。撰寫 manuscript/ch03-model-provider.md、manuscript/ch04-skills.md 和 research/opencode-ch03-ch04-sources.md。只修改自己的章節與研究檔，不修改共用狀態。驗證 hermes model、setup、auth、fallback、Skills Hub、SKILL.md 和 /learn。完成後執行 git diff --check，提交變更，並回報檔案、來源、實測命令、未驗證內容和 commit。';;
    pi)
      printf '%s' '讀取 AGENTS.md、notes/writing-plan.md、notes/agent-assignments.md。你負責第 5～7 章。撰寫 manuscript/ch05-delegation.md、manuscript/ch06-messaging.md、manuscript/ch07-cron.md 和 research/pi-ch05-ch07-sources.md。只修改自己的章節與研究檔，不修改共用狀態。重點驗證 delegate_task、Telegram／Discord 安全、Gateway 和 Cron。完成後執行 git diff --check，提交變更，並回報檔案、來源、實測命令、未驗證內容和 commit。';;
    *) die "未知 Agent：$1";;
  esac
}

worktree_path() { printf '%s/%s' "$WORKTREE_ROOT" "$1"; }
pid_path() { printf '%s/%s.pid' "$RUN_ROOT" "$1"; }
log_path() { printf '%s/%s.log' "$RUN_ROOT" "$1"; }

prepare_worktree() {
  local agent="$1" path branch
  path="$(worktree_path "$agent")"
  branch="agent/$agent"
  mkdir -p "$WORKTREE_ROOT"

  if [[ -e "$path" ]]; then
    [[ -d "$path/.git" || -f "$path/.git" ]] || die "$path 不是 Git worktree"
    [[ "$(git -C "$path" branch --show-current)" == "$branch" ]] || die "$path 的分支不是 $branch"
    [[ -z "$(git -C "$path" status --porcelain)" ]] || die "$path 有未提交變更；請先處理"
    log "重用 worktree：$path"
  else
    git -C "$REPO_DIR" worktree add -b "$branch" "$path" main
    log "建立 worktree：$path"
  fi
}

start_agent() {
  local agent="$1" path log_file pid_file prompt
  path="$(worktree_path "$agent")"
  log_file="$(log_path "$agent")"
  pid_file="$(pid_path "$agent")"
  prompt="$(agent_prompt "$agent")"

  if [[ -f "$pid_file" ]] && kill -0 "$(<"$pid_file")" 2>/dev/null; then
    log "$agent 已在執行中（PID $(<"$pid_file")）"
    return
  fi

  case "$agent" in
    codex)
      nohup codex exec --sandbox workspace-write -C "$path" "$prompt" >"$log_file" 2>&1 &
      ;;
    opencode)
      nohup opencode run --dir "$path" "$prompt" >"$log_file" 2>&1 &
      ;;
    pi)
      nohup pi -p --session-dir "$path/.pi-sessions" \
        --append-system-prompt "$path/AGENTS.md" -- "$prompt" >"$log_file" 2>&1 &
      ;;
  esac
  echo "$!" >"$pid_file"
  log "$agent 已啟動（PID $(<"$pid_file")，log: $log_file）"
}

show_status() {
  local agent pid_file pid
  for agent in codex opencode pi; do
    pid_file="$(pid_path "$agent")"
    if [[ -f "$pid_file" ]]; then
      pid="$(<"$pid_file")"
      if kill -0 "$pid" 2>/dev/null; then
        printf '%-10s RUNNING PID=%s LOG=%s\n' "$agent" "$pid" "$(log_path "$agent")"
      else
        printf '%-10s STOPPED PID=%s LOG=%s\n' "$agent" "$pid" "$(log_path "$agent")"
      fi
    else
      printf '%-10s NOT_STARTED\n' "$agent"
    fi
  done
}

stop_agents() {
  local agent pid_file pid
  for agent in codex opencode pi; do
    pid_file="$(pid_path "$agent")"
    [[ -f "$pid_file" ]] || continue
    pid="$(<"$pid_file")"
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" || true
      log "已停止 $agent（PID $pid）"
    fi
    rm -f "$pid_file"
  done
}

main() {
  cd "$REPO_DIR"
  mkdir -p "$RUN_ROOT"

  case "$ACTION" in
    status)
      show_status
      exit 0
      ;;
    stop)
      stop_agents
      exit 0
      ;;
    dry-run)
      for agent in codex opencode pi; do
        printf '\n[%s]\n%s\n' "$agent" "$(agent_prompt "$agent")"
      done
      if command -v antigravity >/dev/null 2>&1; then
        log 'antigravity 已找到；請依 notes/launch-runbook.md 建立其 worktree。'
      else
        log '警告：找不到 antigravity，跳過第 8～9 章。'
      fi
      exit 0
      ;;
    start)
      require_cmd git
      require_cmd codex
      require_cmd opencode
      require_cmd pi
      [[ -z "$(git status --porcelain)" ]] || die '主工作目錄有未提交變更，請先提交或暫存。'
      for agent in codex opencode pi; do
        prepare_worktree "$agent"
      done
      start_agent codex
      start_agent opencode
      start_agent pi
      if command -v antigravity >/dev/null 2>&1; then
        log 'antigravity 已找到，但本腳本不自動啟動 GUI Agent；請依 runbook 手動啟動。'
      else
        log '警告：找不到 antigravity，尚未分配第 8～9 章的執行程序。'
      fi
      log '全部可用 Agent 已啟動。使用：scripts/start-writing-agents.sh status'
      ;;
    *)
      die "用法：$0 [start|dry-run|status|stop]"
      ;;
  esac
}

main "$@"
