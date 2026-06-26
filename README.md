# session-to-skill

**Language:** **中文** | [English](README.en.md)

一个 skill，在工作会话结束时自动从对话中提炼项目约定和协作偏好，生成随时可保存的项目专属 skill 文件——无需手动编写。

## 工作原理

会话结束时，当你说"谢谢"、"收工"、"done"等收尾语，Claude 会：

1. **扫描本次对话**，提炼明确出现的约定和偏好
2. **找到或创建**该项目的专属 skill 文件：`~/.claude/skills/<项目名>-skill/SKILL.md`
3. **输出结构化 markdown**——首次使用输出完整文件，后续只输出新增内容

每个项目有且只有一个专属 skill 文件，绝不干扰其他项目的 skill。

## 示例

你在一个叫 `my-app` 的项目中结束了一次会话，其中说过"始终用具名导出"和"写代码前先给我看计划"（说了两次）。你输入：*"谢谢，今天就这样了！"*

Claude 回复：

```
不客气！这次会话很顺利。

---
---
name: my-app-skill
description: Use when working on the my-app project. Loads project-specific
conventions and workflow preferences extracted from past sessions.
---

## Project Conventions
- 始终使用具名导出，禁止 default export

## Workflow Preferences
- 写代码前必须先给出计划（对话中确认 ≥ 2 次）

---
> 保存路径：~/.claude/skills/my-app-skill/SKILL.md
```

下次会话结束时，只输出新增内容——已有的条目不会重复出现。

## 安装

**第一步：clone 仓库**

```bash
git clone https://github.com/<your-username>/session-to-skill.git
cd session-to-skill
```

**第二步：安装 skill**

```bash
cp -r skills/session-to-skill ~/.claude/skills/
```

**第三步：在 CLAUDE.md 中加入全局触发规则**

```bash
cat CLAUDE.md.patch >> ~/.claude/CLAUDE.md
```

完成。后续会话结束时 skill 会自动激活。

## 提炼内容说明

**项目约定** — 仅在明确出现信号时提炼：

- 你纠正了 Claude 的做法（"不要这样"、"用 X 代替"）
- 你确认了某个非显而易见的选择（"对就这样"、"很好保持这个风格"）
- 你做出了明确的技术/命名/结构决策

**协作偏好** — 仅在明确出现信号时提炼：

- 你要求了特定的工作流步骤（"先给我看计划"、"改完别直接 commit"）
- 你明确排斥某种行为（"别加注释"、"不要自动 push"）
- 同一模式在对话中出现 ≥ 2 次

不推断，不猜测。一次性请求永远不会被当作约定。

## 文件管理

每个项目有且只有一个专属 skill 文件，Claude 绝不修改其他项目的 skill。

```
会话结束时：
1. ~/.claude/skills/<项目名>-skill/SKILL.md 不存在？
   → 输出完整文件内容，首次创建

2. 文件已存在？
   → 只输出新增内容，已有条目跳过（去重）

3. 文件达到 200 行？
   → 拆分为总览 SKILL.md + reference/topic.md
```

项目名取自 git 仓库名，或当前工作目录名。

## 触发条件

满足以下任一条件时激活：

- 独立的收尾消息：`done` / `thanks` / `谢谢` / `收工` / `完成了` / `就这样` / `好了`
- 主要任务已完成，无新需求，最后几条消息为确认性质
- 明确请求：`"生成 skill"` / `"总结一下"` / `"帮我提炼 skill"` / `"generate skill"`

**不触发**：`"嗯"`、`"ok"`、会话中途的确认、或任何提出新问题的消息。

## 兼容性

支持 Claude Code 及所有兼容 [Agent Skills](https://agentskills.io/specification) 规范的 agent（Codex 等）。

## 目录结构

```
skills/session-to-skill/
  SKILL.md              # Skill 本体
CLAUDE.md.patch         # 追加到 ~/.claude/CLAUDE.md 的触发规则
docs/superpowers/
  specs/                # 设计文档（v1）
  plans/                # 实现计划
```

## 许可证

MIT