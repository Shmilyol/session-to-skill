# session-to-skill v2 Change Log

**Date:** 2026-06-26  
**Status:** Completed  
**Spec:** [v2.0 Design](../specs/2026-06-26-session-to-skill-design-v2.md)

---

## 本次改动概览

### 问题一：skill 写入了 memory 目录而非 skills 目录

**根因：** auto-memory 系统（ECC harness 注入）会立即捕获任何偏好信号写入 `~/.claude/projects/.../memory/`，与 session-to-skill 的延迟写入逻辑冲突，导致内容落入错误位置。

**修复：**
- SKILL.md 新增 `CRITICAL — Memory system is forbidden here` 强制说明
- 将输出方式从"输出 markdown 供用户保存"改为"Claude 用 Write 工具直接写入 `~/.claude/skills/`"

---

### 问题二：会话中途的偏好信号未被捕获

**根因：** 原触发条件只在会话结束时激活，中途出现的明确偏好词（"不要"、"你应该"等）被 auto-memory 抢先捕获。

**修复：**
- 新增 Trigger Condition 3：Mid-session preference signal
- 检测到拒绝词（`不要` / `别` / `don't`）或推荐词（`你应该` / `always`）时，立即询问是否写入 skill

---

### 问题三：SKILL.md 过于臃肿

**根因：** 经过多次迭代追加，SKILL.md 膨胀至 217 行，超过 180 行阈值，且中英文混杂。

**修复：**
- 按 writing-skills 规范重构，压缩至 88 行
- 触发条件按类型拆分为 4 个渐进式子标题
- /compact 提示模板提取至 `reference/compact-reminder.md`
- 删除通用 skill 写法说明（Description Field Rules）
- 统一使用英文，用户触发词以 `e.g.` 示例形式保留

---

### 问题四：Confirm Before Writing 措辞与实际行为不符

**根因：** 确认消息模板中仍有"输出完整内容供你保存"字样，与直接写入的新行为矛盾。

**修复：** 删除该措辞，改为"Shall I write the file now?"

---

## 文件变更清单

| 操作 | 路径 |
|------|------|
| 修改 | `skills/session-to-skill/SKILL.md` |
| 新建 | `skills/session-to-skill/reference/compact-reminder.md` |
| 修改 | `README.md` |
| 修改 | `README.en.md` |
| 新建 | `docs/superpowers/specs/2026-06-26-session-to-skill-design-v2.md` |
| 新建 | `docs/superpowers/plans/2026-06-26-session-to-skill-v2.md`（本文件） |
