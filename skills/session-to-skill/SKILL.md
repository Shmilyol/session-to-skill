---
name: session-to-skill
description: Use when a session is ending (user's message conveys a closing/wrap-up intent), all tasks are complete with no new requests, the user explicitly asks to generate or extract a skill, or a mid-session preference signal is detected. Writes project conventions and workflow preferences to ~/.claude/skills/<project-name>-skill/SKILL.md.
---

# Session to Skill

Capture project conventions and workflow preferences from the current conversation and write them
directly to `~/.claude/skills/<project-name>-skill/SKILL.md`. **Never write to the memory system.**

## Trigger Conditions

### 1. End-of-session

User's message conveys a **session-closing intent** — they are wrapping up, expressing gratitude
for the session, or signaling they're done for now. Detect by semantic meaning, not exact words
(e.g. "done", "thanks", "谢谢", "收工" are illustrative, not exhaustive). Also triggers when all
tasks are complete with no new requests.

### 2. Explicit request

User explicitly asks to **generate, extract, or summarize** the session into a skill file. Detect
by intent, not exact phrase (e.g. "generate skill", "生成 skill", "总结一下" are illustrative).

### 3. Mid-session preference signal

User's message expresses a **preference signal** — **immediately ask** whether to record it.
Detect by **semantic intent**, not exact keywords. Examples are illustrative, not exhaustive:

- **Rejection / exclusion intent** — user signals what they don't want or what to stop doing
  (e.g. "don't", "never", "不要", "别", or any semantically equivalent phrasing)
- **Constraint / narrowing intent** — user limits scope to a specific approach, tool, or behavior
  (e.g. "only", "just X is enough", "就可以", "X 就行", or similar narrowing language)
- **Directive / recommendation intent** — user says what I should always or must do
  (e.g. "you should", "always", "你应该", "你需要", "必须", or similar directive phrasing)

Ask (in the user's language): "Should I record this preference in the project skill?" Extract only
that item if confirmed.

### 4. /compact suggestion

When suggesting `/compact`, append the reminder
from [reference/compact-reminder.md](reference/compact-reminder.md) (translate to the user's
language).

**Do NOT trigger on:** brief acknowledgments, mid-session confirmations, or messages whose intent
is to continue or ask something new — not to close the session or express a preference.

## What to Extract

Extract **only** when explicitly signaled — never infer:

**Project Conventions:** user corrected approach / confirmed non-obvious choice / made explicit tech
or naming decision

**Workflow Preferences:** user required a specific step / rejected a behavior / same pattern
appeared ≥ 2 times

**Hard filter:** Ambiguous signal → skip. One-off request → never a convention. Nothing passes →
silently skip.

## Write Rules

**Path:** `~/.claude/skills/<project-name>-skill/SKILL.md` — never `~/.claude/projects/.../memory/`

**Project name** (priority order): `git rev-parse --show-toplevel | xargs basename` → working
directory name → ask user

**Decision:**

- File doesn't exist → create full file
- File exists, stays ≤ 180 lines → Read, merge new items (skip duplicates), Write
- File would exceed 180 lines → split: SKILL.md becomes a slim index; move bullets to
  `reference/conventions.md` and `reference/workflow.md`

## Confirm Before Writing

Show a preview (in the user's language) and wait for confirmation:

```
Extracted the following, ready to [create | append to | split] `~/.claude/skills/<project-name>-skill/SKILL.md`:

**Project Conventions (new)**
- <item>

**Workflow Preferences (new)**
- <item>

Shall I write the file now?
```

- Confirmed → use Write tool directly; never output raw skill content in chat
- Declined → silently skip
- Nothing extracted → skip confirmation entirely

After writing, confirm path to user (in their language).

## Generated File Format

```markdown
---
name: <project-name>-skill
description: Use when working on <project-name>. Loads project-specific conventions from past sessions.
---

## Project Conventions

- <item>

## Workflow Preferences

- <item>
```

Naming: lowercase, hyphen-separated, gerund form preferred. Never generic names (`utils`, `misc`,
`general`).
