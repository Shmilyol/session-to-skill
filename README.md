# session-to-skill

A skill that automatically extracts project conventions and workflow preferences from your work session and generates a ready-to-save project skill file — without you having to write one manually.

## How it works

At the end of a session, when you say "thanks", "done", "收工", or similar, Claude:

1. **Scans the conversation** for explicitly stated conventions and preferences
2. **Finds or creates** a single dedicated skill file for this project: `~/.claude/skills/<project-name>-skill/SKILL.md`
3. **Outputs structured markdown** — a full file on first use, or just the new items to append on subsequent sessions

Each project gets exactly one skill file. It never touches any other project's skills.

## Example

You finish a session on a project called `my-app` where you said "always use named exports" and "show me a plan before coding" (twice). You type: *"Thanks, done for today!"*

Claude responds:

```
You're welcome! Great session.

---
---
name: my-app-skill
description: Use when working on the my-app project. Loads project-specific
conventions and workflow preferences extracted from past sessions.
---

## Project Conventions
- Always use named exports — never default exports

## Workflow Preferences
- Always present a plan before writing any code (confirmed ≥ 2 times)

---
> Save to: ~/.claude/skills/my-app-skill/SKILL.md
```

Next session, only new items are output — nothing already in the file is repeated.

## Installation

**Step 1: Install the skill**

```bash
cp -r skills/session-to-skill ~/.claude/skills/
```

**Step 2: Add the global trigger to CLAUDE.md**

```bash
cat CLAUDE.md.patch >> ~/.claude/CLAUDE.md
```

That's it. The skill activates automatically at the end of future sessions.

## What gets extracted

**Project Conventions** — only when explicitly signaled:
- You corrected Claude's approach ("don't do it that way", "use X instead")
- You confirmed a non-obvious choice ("yes, exactly like that")
- You made an explicit tech/naming/structure decision

**Workflow Preferences** — only when explicitly signaled:
- You required a specific step ("show me the plan first")
- You rejected a behavior ("don't auto-commit")
- The same pattern appeared ≥ 2 times in the session

Nothing is inferred or guessed. One-off requests are never treated as conventions.

## File management

Each project has exactly one dedicated skill file. Claude never touches other projects' skill files.

```
On session end:
1. ~/.claude/skills/<project-name>-skill/SKILL.md does not exist?
   → Output full file to create

2. File already exists?
   → Output only new items to append; skip duplicates

3. File reaches 200 lines?
   → Split: SKILL.md becomes overview + reference/topic.md
```

Project name is derived from the git repo name, or the working directory name.

## Trigger conditions

Activates on any of:
- Standalone closing message: `done` / `thanks` / `谢谢` / `收工` / `完成了` / `就这样`
- All tasks complete, no new requests, last messages are confirmations
- Explicit request: `"生成 skill"` / `"generate skill"` / `"总结一下"`

Does **not** trigger on: `"嗯"`, `"ok"`, mid-session acknowledgments, or any message asking a new question.

## Compatibility

Works with Claude Code and any agent that supports the [Agent Skills](https://agentskills.io/specification) format (Codex, etc.).

## Repository structure

```
skills/session-to-skill/
  SKILL.md              # The skill itself
CLAUDE.md.patch         # Snippet to append to ~/.claude/CLAUDE.md
docs/superpowers/
  specs/                # Design spec (v1)
  plans/                # Implementation plan
```

## License

MIT
