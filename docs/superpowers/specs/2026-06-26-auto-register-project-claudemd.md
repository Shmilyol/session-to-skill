---
date: 2026-06-26
change: Auto-register project skill in CLAUDE.md after writing skill file
files:
  - skills/session-to-skill/SKILL.md
  - README.md
  - README.en.md
---

# 功能：写入 skill 后自动注册到项目 CLAUDE.md

## 背景

用户指出两个遗漏的保障：

1. 用户新建项目并使用 Claude 时，如何确保 session-to-skill 被触发？
   → 已由 `CLAUDE.md.patch` 追加的全局触发规则覆盖。

2. 用户的项目 skill 生成后，下次会话如何确保它被加载？
   → 原先无保障：Claude 只在 `using-superpowers` 的语义判断下"可能"调用，不可靠。

## 解决方案

采用方案 A：写 skill 文件后，同步将调用指令追加到项目根目录的 `CLAUDE.md`。

Claude Code 每次会话开始时必读项目级 `CLAUDE.md`，因此这条路径是确定性的，
不依赖任何语义推断。

## 实现逻辑

```
写完 ~/.claude/skills/<name>-skill/SKILL.md 后：
1. git rev-parse --show-toplevel → 获取项目根目录
2. 检查 <root>/CLAUDE.md 是否已含 <name>-skill 调用行
3. 已存在 → 跳过（幂等，重复写 skill 不会重复追加）
4. 不存在 → 追加：
   ## Project Skill
   Invoke the `<name>-skill` skill at the start of every session using the Skill tool.
```

## 影响文件

- `skills/session-to-skill/SKILL.md`：Write Rules 新增 CLAUDE.md 注册步骤；Confirm 预览模板同步
- `README.md`：文件管理流程新增第 4 步
- `README.en.md`：File management 同步
- `~/.claude/skills/session-to-skill/SKILL.md`：同步

## 效果

首次写入项目 skill 后，该项目的每次后续会话都会在 session 开始时确定性地加载对应 skill，
无需用户额外操作。
