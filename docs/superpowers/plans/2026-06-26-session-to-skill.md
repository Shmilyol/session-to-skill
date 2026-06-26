# session-to-skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建 `session-to-skill` skill，在项目会话自然结束时自动从对话提炼项目约定和协作偏好，以 markdown 展示在响应末尾供用户保存。

**Architecture:** 采用 CLAUDE.md 全局触发规则 + SKILL.md 本体的两文件结构。Claude 在会话结束信号出现时加载 SKILL.md，扫描已有项目 skill 文件的 description 决定路由，然后输出结构化 skill 内容。所有内容来自当前对话上下文，无需读取外部文件或调用 API。

**Tech Stack:** Markdown, YAML frontmatter, Claude Code skill system

---

## 文件清单

| 操作 | 路径 | 部署目标 |
|------|------|---------|
| 新建 | `skills/session-to-skill/SKILL.md` | 复制到 `~/.claude/skills/session-to-skill/SKILL.md` |
| 新建 | `CLAUDE.md.patch` | 追加内容到 `~/.claude/CLAUDE.md` |

---

## Task 1：运行基线场景（RED）✅

**基线结果：** subagent 只回复收尾寒暄，完全不生成任何 skill 格式内容——无 `---`，无 YAML frontmatter，无结构化输出。RED 阶段通过。

---

## Task 2：编写 SKILL.md（GREEN）✅

`skills/session-to-skill/SKILL.md` 已写入，100 行 ≤ 200。

---

## Task 3：验证 skill 生效（GREEN verify）✅

全部通过：`---` 分隔线 ✅ / YAML frontmatter ✅ / named exports ✅ / Zod ✅ / plan-before-coding ✅ / When NOT to use ✅ / 保存路径 ✅

**Minor 发现（Task 4 已修复）：**
1. 生成的 description 混入 skill 内容摘要 → 加入 ❌/✅ 示例
2. 未先回复用户 → 加入"先回复用户"指令

---

## Task 4：关闭漏洞（REFACTOR）✅

边界场景全部通过：
- 场景 A（"嗯"）: NO — 正确拒绝模糊信号
- 场景 B（短会话 + thanks）: NO — hard filter 正确过滤
- 场景 C（内容丰富但无结束信号）: NO — 必须有结束信号

---

## Task 5：CLAUDE.md patch ✅

`CLAUDE.md.patch` 已写入。

**部署命令：**
```bash
cp -r skills/session-to-skill ~/.claude/skills/
cat CLAUDE.md.patch >> ~/.claude/CLAUDE.md
```
