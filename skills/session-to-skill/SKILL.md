---
name: session-to-skill
description: Use when a project session is ending and the user expresses completion (says "done", "thanks", "收工", "完成了", etc.), when all main tasks are complete with no new requests and last messages are confirmations, or when the user explicitly asks to generate or summarize a project skill. Extracts project conventions and workflow preferences from the current conversation and outputs structured skill content.
---

# Session to Skill

## Overview

At the natural end of a work session, extract project conventions and workflow preferences from the current conversation and output structured skill content after a `---` separator. The user saves it manually.

## Trigger Conditions

Activate when ANY of these occur:
- User sends a standalone closing message: done / thanks / 谢谢 / 收工 / 完成了 / 就这样 / 好了
- All main tasks complete, no pending requests, last few messages are confirmations
- User explicitly says: "生成 skill" / "总结一下" / "帮我提炼 skill" / "generate skill"

**Do NOT trigger on:** Ambiguous single-character responses ("嗯", "ok", "好"), mid-conversation acknowledgments, or messages where the user asks a new question. A closing signal is always required — content richness alone is not sufficient.

## What to Extract

### Project Conventions
Extract ONLY when explicitly signaled — never inferred:
- User corrected Claude's approach ("don't do it that way", "use X instead")
- User confirmed a non-obvious choice ("yes, exactly like that", "对就这样")
- Explicit decisions about tech choices, file structure, or naming rules

### Workflow Preferences
Extract ONLY when explicitly signaled:
- User required a specific workflow step ("show me the plan first", "先给我看计划")
- User rejected a behavior ("don't add comments", "别自动 commit")
- Same pattern appeared ≥ 2 times in the conversation

**Hard filter:** No inference. No guessing. If a signal is ambiguous, skip it. One-off context (e.g., "fix this file") is never a convention. If no signals pass the filter, generate nothing — silently skip.

## Routing Logic

Before generating output, scan `~/.claude/skills/<project>-skills/` for existing files.
Read each file's `description` field to understand its scope.

```
For each extracted item:
1. Already exists as identical or highly similar bullet? → Skip (deduplicate)
2. Existing file description semantically matches + file < 200 lines? → Append to that file
3. Existing file matches but ≥ 200 lines? → Split: SKILL.md stays as overview,
   move heavy content to reference/topic.md; update both descriptions
4. No matching file exists? → Create new file with gerund name + description
```

When project has 2+ skill files: maintain `<project>-skills/INDEX.md` listing all files and their scope.

## Output Format

First respond naturally to the user's closing message (e.g., "You're welcome! Great session."), then append skill content after a `---` separator:

````markdown
---
name: <gerund-form-name, e.g. managing-api-conventions>
description: Use when <specific trigger>. <Third person. No workflow summary.>
---

## Project Conventions
- <convention>

## Workflow Preferences
- <preference>

## When NOT to use
- <what this file does NOT cover>

---
> Save to: ~/.claude/skills/<project>-skills/<filename>.md
````

## Naming Rules
- Gerund form: `managing-api-conventions` not `api-conventions`
- Lowercase, hyphen-separated, no special characters
- Specific scope — never generic (`utils`, `misc`, `general` are forbidden)

## Description Field Rules
- Start with "Use when..."
- Third person only (injected into system prompt)
- Triggering conditions ONLY — never summarize what the skill enforces or contains
- Under 500 characters
- Include searchable keywords (project name, scenario words, tech names)

```
# ❌ BAD: summarizes skill content
description: Use when session ends. Enforces named exports and Zod validation.

# ✅ GOOD: only triggering conditions
description: Use when working on <project> and session is ending (user says done/thanks/收工),
or user asks to generate a project skill. Loads project-specific conventions from this session.
```

## Line Limit
- Each SKILL.md: max 200 lines
- If a file hits 200 lines: SKILL.md becomes overview + links; heavy content goes to `reference/topic.md`
- References max 1 level deep — no nested references
