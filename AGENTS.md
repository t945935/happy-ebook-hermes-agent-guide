# Agent Handoff Rules

## Project

- Book: Hermes Agent 操作手冊
- Subtitle: 從第一次安裝到多平台 AI 助理
- Author: Happy eBook Authors
- Publisher: Happy eBook
- Reader-service repository: https://github.com/t945935/happy-ebook-hermes-agent-guide

## Mission

Produce a practical, reader-facing Traditional Chinese guide for beginners and technical users. Every chapter must teach an observable task and include a verification path. Do not claim a feature, command, version, platform, or successful execution without current official documentation or recorded execution evidence.

## Source of truth

- Writing plan: `notes/writing-plan.md`
- Chapter status: `notes/chapter-status.yaml`
- Draft chapters: `manuscript/`
- Research and citations: `research/`
- Images and diagrams: `assets/`
- Editorial notes: `notes/`
- Exported artifacts: `output/`

## Handoff protocol

Before starting:

1. Read `notes/writing-plan.md` and this file.
2. Read `notes/chapter-status.yaml`.
3. Check `git status --short`.
4. Claim only the chapter or task assigned in the handoff message.
5. Do not overwrite another agent's work; stop and report if the target changed.

For each completed task, return:

- Files changed
- Sources consulted, with URLs or commands
- Commands actually run and their exit results
- Reader-facing claims that remain unverified
- Remaining blockers
- Recommended next task

## Editing rules

- Write in Traditional Chinese; preserve commands, identifiers, URLs, environment variables, and model names exactly.
- Keep secrets, tokens, credentials, local paths, and private logs out of the repository.
- Use `hermes config set` for configuration instructions; do not tell readers to hand-edit `config.yaml` unless the official workflow requires a file block and the limitation is explained.
- Distinguish documented behavior, locally verified behavior, illustrative examples, and unverified assumptions.
- A heading, command list, or generic checklist is not a completed chapter. Each chapter needs purpose, prerequisites, worked procedure, expected evidence, failure recovery, practice task, and completion criteria.
- Do not publish unpublished manuscript files, ebook deliverables, covers, author-only builders, or runtime evidence in this reader-service repository unless explicitly authorized.

## Git rules

- Use focused commits.
- Do not amend or rewrite another agent's commit.
- Do not push credentials or generated caches.
- Before handoff, run `git diff --check` and report the result.
