#!/bin/bash
set -e

SKILL_DIR="$HOME/.claude/skills/session-to-skill"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
RAW="https://raw.githubusercontent.com/Shmilyol/session-to-skill/main"

echo "Installing session-to-skill..."

# Install SKILL.md
if [ -f "$SKILL_DIR/SKILL.md" ]; then
  echo "✓ Skill already installed at $SKILL_DIR, updating..."
else
  echo "→ Creating $SKILL_DIR"
  mkdir -p "$SKILL_DIR"
fi

curl -fsSL "$RAW/skills/session-to-skill/SKILL.md" -o "$SKILL_DIR/SKILL.md"
echo "✓ SKILL.md installed"

# Append CLAUDE.md.patch (skip if already applied)
PATCH_MARKER="Session Skill Generation"
if [ -f "$CLAUDE_MD" ] && grep -q "$PATCH_MARKER" "$CLAUDE_MD"; then
  echo "✓ CLAUDE.md trigger already present, skipping"
else
  curl -fsSL "$RAW/CLAUDE.md.patch" >> "$CLAUDE_MD"
  echo "✓ CLAUDE.md trigger added"
fi

echo ""
echo "Done! session-to-skill is ready. It will activate automatically at the end of future sessions."
