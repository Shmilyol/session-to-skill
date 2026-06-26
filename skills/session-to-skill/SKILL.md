---
name: session-to-skill
description: Use when a project session is ending and the user expresses completion (says "done", "thanks", "收工", "完成了", etc.), when all main tasks are complete with no new requests and last messages are confirmations, or when the user explicitly asks to generate or summarize a project skill. Extracts project conventions and workflow preferences from the current conversation and outputs structured skill content.
---

# Session to Skill

## Overview

At the natural end of a work session, extract project conventions and workflow preferences from the current conversation and write them to `~/.claude/skills/<project-name>-skill/SKILL.md` using the Write tool after user confirmation.

## Trigger Conditions

Activate when ANY of these occur:
- User sends a standalone closing message: done / thanks / 谢谢 / 收工 / 完成了 / 就这样 / 好了
- All main tasks complete, no pending requests, last few messages are confirmations
- User explicitly says: "生成 skill" / "总结一下" / "帮我提炼 skill" / "generate skill"

- Context is approaching its limit and Claude suggests `/compact` — detect the language the user has been writing in, then append to the suggestion in that same language:

  **Template (translate into the user's language before sending):**

  > Also, consider running **session-to-skill** before compacting.
  >
  > session-to-skill scans this conversation and extracts any explicit project conventions you've established with Claude — things like "always use named exports" or "show me a plan before coding" — and saves them to a dedicated skill file for this project. Next time you open a new session, Claude will load these conventions automatically, so you never have to repeat yourself.
  >
  > If you skip this now, those agreements will be lost after /compact and you'll need to re-establish them. Want to run it now?

- Mid-session preference signal detected — user's message contains explicit rejection or acceptance keywords such as: "不要"、"别"、"just X"、"only X"、"就可以"、"不用"、"X就行"、"don't"、"stop doing"、"never" — immediately ask: "这条偏好要记录到项目 skill 里吗？" (translate to user's language). If user confirms, proceed to extract and write.

**Do NOT trigger on:** Ambiguous single-character responses ("嗯", "ok", "好"), mid-conversation acknowledgments, or messages where the user asks a new question. A closing signal or explicit preference signal is always required — content richness alone is not sufficient.

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

## Project Skill File

Each project gets exactly one dedicated skill directory: `~/.claude/skills/<project-name>-skill/`.
**Never read, write, or modify any other project's skill files.**

**CRITICAL — Memory system is forbidden here:**
- Do NOT write any extracted content to the auto-memory system (`~/.claude/projects/.../memory/`)
- Do NOT treat extracted conventions or preferences as "project memories" or "feedback memories"
- Skill output goes ONLY to `~/.claude/skills/<project-name>-skill/SKILL.md`
- Memory ≠ Skill: the memory system is for session context; skills are loaded via the Skill tool

Determine `<project-name>` from (in priority order):
1. Git repo name (`git rev-parse --show-toplevel | xargs basename`)
2. Current working directory name
3. Ask the user if neither is available

```
On session end:
1. Does ~/.claude/skills/<project-name>-skill/SKILL.md exist?
   - No  → Output full new file (see "First session" format below)
   - Yes → Read the file; count current lines → go to step 2

2. current_lines + estimated_new_lines ≤ 180?
   - Yes → Output new items only; skip duplicates (see "Subsequent sessions" format)
   - No  → Trigger split (see "Split" format below)
```

## Confirm Before Output

Before outputting any skill content, show the user a confirmation message and wait for their response.

**Confirmation message format:**

```
本次会话提炼到以下内容，准备 [新建 | 追加到 | 拆分] `~/.claude/skills/<project-name>-skill/SKILL.md`：

**Project Conventions（新增）**
- <item>

**Workflow Preferences（新增）**
- <item>

确认后我会输出完整内容供你保存。继续吗？
```

**User confirms** (yes / 好 / 确认 / ok / 继续 / ✅) → proceed to Output Format below.
**User declines** (no / 不用 / 跳过 / cancel) → silently skip, output nothing.
**No extractable content** → skip the confirmation entirely, output nothing.

Do NOT output any skill content before receiving confirmation.

## Output Format

First respond naturally to the user's closing message (e.g., "You're welcome! Great session."), then use the Write tool to save the skill file directly. Never output raw skill content in the chat — write it to disk.

**First session (file does not exist yet):** use Write tool to create `~/.claude/skills/<project-name>-skill/SKILL.md`:

```
---
name: <project-name>-skill
description: Use when working on <project-name> project. Loads project-specific
conventions and workflow preferences extracted from past sessions.
---

## Project Conventions
- <convention>

## Workflow Preferences
- <preference>
```

**Subsequent sessions (file already exists, ≤ 180 lines after adding):** use Read to load existing content, merge new items, then use Write to overwrite the file with the merged result. Skip any items already present.

**Split (file would exceed 180 lines after adding):** use Write to:
1. Overwrite `~/.claude/skills/<project-name>-skill/SKILL.md` with a slim index:
```
---
name: <project-name>-skill
description: Use when working on <project-name> project. Loads project-specific
conventions and workflow preferences extracted from past sessions.
---

## Project Conventions
See [reference/conventions.md](reference/conventions.md)

## Workflow Preferences
See [reference/workflow.md](reference/workflow.md)
```
2. Create `~/.claude/skills/<project-name>-skill/reference/conventions.md` with all conventions
3. Create `~/.claude/skills/<project-name>-skill/reference/workflow.md` with all workflow preferences

After writing, confirm the path to the user: "已保存到 `~/.claude/skills/<project-name>-skill/SKILL.md`"

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
- Threshold: 180 lines (20-line buffer before hard 200-line cap)
- Split target: SKILL.md → overview with links only; bullets move to `reference/conventions.md` and `reference/workflow.md`
- References max 1 level deep — `reference/` files must never link to further sub-files
- After a split, subsequent sessions append to the `reference/` files, not to SKILL.md
