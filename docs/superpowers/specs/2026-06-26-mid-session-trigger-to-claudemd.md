---
date: 2026-06-26
change: Move mid-session preference detection trigger from SKILL.md to CLAUDE.md.patch
files:
  - CLAUDE.md.patch
  - skills/session-to-skill/SKILL.md
  - README.md
  - README.en.md
---

# 修复：中途偏好检测移至 CLAUDE.md，变为全局常驻规则

## 问题

mid-session 偏好信号检测逻辑写在 SKILL.md 里。SKILL.md 只有被显式调用才生效，
如果 Claude 漏调了 session-to-skill skill，检测就不存在，偏好信号会被 auto-memory
或其他机制错误处理。

## 根本原因

两个系统争同一类信号：
- **Auto-memory**（全局 CLAUDE.md 始终激活）：检测到用户偏好 → 直接写 memory
- **Session-to-skill 中途检测**（仅 skill 加载后生效）：应先询问是否记录到项目 skill

skill 未加载时，auto-memory 先匹配，session-to-skill 逻辑不存在。

## 解决方案

将触发逻辑从 SKILL.md 移到 `CLAUDE.md.patch`，新增 `## Mid-session Preference Detection` 节：

```
When a user message conveys rejection, narrowing, or directive intent — detected by semantic
meaning, not exact keywords — immediately ask (in the user's language): "Should I record this
preference in the project skill?"

If confirmed: invoke the `session-to-skill` skill and follow its extraction and write rules,
recording only that preference item.
```

SKILL.md Section 3 保留意图类型说明，但注明触发来自 CLAUDE.md，skill 本身只负责提取和写入。

## 效果

中途偏好检测变为全局常驻行为，与 Session Skill Generation 触发同级，
不再依赖 session-to-skill-skill 是否被加载。

## 已更新文件

- `CLAUDE.md.patch`：新增 Mid-session Preference Detection 节
- `~/.claude/CLAUDE.md`：同步（已安装用户立即生效）
- `skills/session-to-skill/SKILL.md`：Section 3 更新为"触发来自 CLAUDE.md"
- `~/.claude/skills/session-to-skill/SKILL.md`：同步
- `README.md` / `README.en.md`：触发说明补充"全局常驻"说明
