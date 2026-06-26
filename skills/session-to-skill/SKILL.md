---
name: session-to-skill
description: Use when a project session is ending (user says done/thanks/收工/完成了), all tasks are complete, the user explicitly requests skill generation, or a mid-session preference signal is detected. Writes project conventions and workflow preferences to ~/.claude/skills/<project-name>-skill/SKILL.md.
---

# Session to Skill

Capture project conventions and workflow preferences from the current conversation and write them
directly to `~/.claude/skills/<project-name>-skill/SKILL.md`. **Never write to the memory system.**

## Trigger Conditions

### 1. End-of-session

User sends a standalone closing word, e.g.: `done`, `thanks`, `谢谢`, `收工`, `完成了`, `就这样`,
`好了` — or all tasks are complete with no new requests.

### 2. Explicit request

User asks, e.g.: `generate skill`, `生成 skill`, `总结一下`, `帮我提炼 skill`

### 3. Mid-session preference signal

User's message contains a rejection, acceptance, or recommendation keyword — **immediately ask**
whether to record it:

- Rejection/acceptance, e.g.: `don't` / `never` / `only X` / `just X` / `不要` / `别` / `就可以` /
  `不用` / `X就行`
- Recommendation, e.g.: `you should` / `you need to` / `always` / `你应该` / `你需要` / `必须`

Ask (in the user's language): "Should I record this preference in the project skill?" Extract only
that item if confirmed.

### 4. /compact suggestion

When suggesting `/compact`, append the reminder
from [reference/compact-reminder.md](reference/compact-reminder.md) (translate to the user's
language).

**Do NOT trigger on:** `嗯`, `ok`, `好`, mid-session confirmations, or messages asking a new
question.

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
