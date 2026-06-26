# session-to-skill

**Language:** [中文](README.md) | **English**

A skill that automatically extracts project conventions and workflow preferences from your work session and writes them directly to a project skill file — no manual writing, no manual saving.

## How it works

At the end of a session, when you say "thanks", "done", "收工", or similar, Claude:

1. **Scans the conversation** for explicitly stated conventions and preferences
2. **Shows a preview and asks for confirmation** before writing anything
3. **Writes directly** to the project's dedicated skill file: `~/.claude/skills/<project-name>-skill/SKILL.md`

Each project gets exactly one skill file. It never touches any other project's skills.

## Example

You finish a session on a project called `my-app` where you said "always use named exports" and "show me a plan before coding" (twice). You type: *"Thanks, done for today!"*

Claude responds:

```
Extracted the following from this session, ready to create
`~/.claude/skills/my-app-skill/SKILL.md`:

**Project Conventions (new)**
- Always use named exports — never default exports

**Workflow Preferences (new)**
- Always present a plan before writing any code (confirmed ≥ 2 times)

Shall I write the file now?
```

You reply "yes", and Claude writes the file directly, then confirms:

```
You're welcome! Great session.
Saved to `~/.claude/skills/my-app-skill/SKILL.md`
```

Next session, only new items are written — nothing already in the file is repeated.

## Installation

### Option 1: One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/Shmilyol/session-to-skill/main/install.sh | bash
```

The script will:
- Download the skill to `~/.claude/skills/session-to-skill/`
- Append the trigger rule to `~/.claude/CLAUDE.md`
- Skip if already installed (safe to re-run)

### Option 2: Manual install

```bash
# Clone the repository
git clone https://github.com/Shmilyol/session-to-skill.git
cd session-to-skill

# Install the skill
cp -r skills/session-to-skill ~/.claude/skills/

# Add the global trigger
cat CLAUDE.md.patch >> ~/.claude/CLAUDE.md
```

The skill activates automatically at the end of future sessions.

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
