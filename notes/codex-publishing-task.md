# Codex Publishing Package Task

## Goal

為《Hermes Agent 操作手冊：從第一次安裝到多平台 AI 助理》準備出版前的封面與商店 metadata 草案，供作者審查。這不是上架授權；不得登入、上傳、發布或修改 Google Play Books／Kobo 帳戶。

## Book identity

- Title: Hermes Agent 操作手冊
- Subtitle: 從第一次安裝到多平台 AI 助理
- Author: Happy eBook Authors
- Publisher: Happy eBook
- Language: Traditional Chinese (`zh-Hant`)
- Reader-service repository: https://github.com/t945935/happy-ebook-hermes-agent-guide

## Required deliverables

Create only the following task files/assets:

1. `assets/cover-draft/cover.svg` — editable cover source.
2. `assets/cover-draft/cover-preview.png` — preview only if a real conversion tool is available; report the actual tool and result.
3. `assets/cover-draft/cover-brief.md` — design rationale, dimensions, fonts, colors, accessibility/legibility notes, and rights/trademark notes.
4. `notes/publishing-metadata-draft.md` — complete metadata draft:
   - title, subtitle, author, publisher, language
   - short description and long description
   - keyword list
   - author/publisher display text
   - reader-service URL
   - a clear non-affiliation statement: this is an independent guide and is not an official Nous Research publication unless verified otherwise
5. `notes/store-categories-pricing-draft.md` — separate proposals for Google Play Books and Kobo:
   - current category path or the closest verified live taxonomy path
   - rationale tied to actual book content
   - primary and backup category
   - proposed launch price and regular price by currency where supported
   - pricing assumptions and comparable-book evidence
   - mark every proposal as DRAFT / REQUIRES AUTHOR APPROVAL
6. `research/codex-publishing-sources.md` — source ledger with URL, access date, claim supported, and whether the claim was actually verified.

## Research requirements

- Use current official Google Play Books and Kobo Writing Life documentation for cover, metadata, category, and pricing rules.
- If live store access is unavailable, say so; do not invent category IDs, price floors, tax rules, or platform requirements.
- Research comparable Traditional Chinese technical or AI ebooks only when the source and price are observable; distinguish list price from sale price.
- Do not claim the book is official, endorsed, certified, or affiliated with Hermes Agent / Nous Research.
- Do not invent ISBN, GGKEY, Kobo identifier, sales data, ranking, or market demand.
- Do not upload anything or change remote services.

## Cover requirements

- Traditional Chinese title must remain readable at thumbnail size.
- Use a professional technical-guide style, not an imitation of official Hermes branding.
- Avoid copying Hermes/Nous logos, official marks, screenshots, or copyrighted imagery.
- Include title, subtitle, author, and publisher only where the layout remains legible.
- Prefer an SVG source with embedded or system-safe font declarations and no remote assets.
- If generating PNG, inspect its real dimensions, color mode, file size, and successful decode.
- If PNG generation is unavailable, leave the SVG and clearly mark PNG as pending; do not fabricate a conversion result.

## Acceptance criteria

- All six deliverables exist or the missing item is explicitly reported as blocked.
- SVG is parseable and contains no external image/network dependency.
- Metadata is consistent with the approved title and author names.
- Google Play and Kobo recommendations are separate, sourced, and not presented as final.
- Price is a proposal, not an automatic publication decision.
- `git diff --check` passes.
- Commit changes on branch `agent/codex-publishing` and return the commit hash plus a concise handoff.
