# session-to-skill Design Spec

**Version:** v2.0  
**Date:** 2026-06-26  
**Status:** Approved  
**Previous:** [v1.1](2026-06-26-session-to-skill-design.md)

---

## 与 v1 的核心差异

| 维度 | v1 | v2 |
|------|----|----|
| 输出方式 | 输出 markdown，用户手动保存 | Claude 用 Write 工具直接写入 |
| 触发时机 | 仅会话结束 | 新增：会话中途偏好信号词 |
| Memory 边界 | 未明确禁止 | 明确禁止写入 memory 系统 |
| 行数阈值 | 200 行 | 180 行（20 行缓冲区） |
| SKILL.md 体积 | 200+ 行 | 88 行（精简重构） |
| 参考模板 | 内联 | 移至 `reference/compact-reminder.md` |

---

## 目标

在项目会话结束或检测到明确偏好信号时，自动从当前对话提炼项目约定和协作偏好，**直接写入**项目专属 skill 文件，无需用户手动保存。

---

## 触发逻辑

四类触发条件，按响应时机分两类：

### 即时响应类（检测到即询问）

**1. 会话中途偏好信号**  
用户消息中出现明确的拒绝、接受或推荐词时，立即询问是否记录：
- 拒绝/接受词：`don't` / `never` / `only X` / `不要` / `别` / `就可以` / `不用`
- 推荐词：`you should` / `always` / `你应该` / `你需要` / `必须`

询问后仅提取该条内容写入，不做全局扫描。

### 延迟响应类（结束时处理）

**2. 会话结尾信号**  
独立收尾词：`done` / `thanks` / `谢谢` / `收工` / `完成了` / `就这样` / `好了`，或主要任务已完成、无新需求。

**3. 用户主动请求**  
`generate skill` / `生成 skill` / `总结一下` / `帮我提炼 skill`

**4. /compact 建议**  
在建议 /compact 时附加提示，模板见 `reference/compact-reminder.md`。

**不触发：** 单字确认（嗯/ok/好）、会话中途普通确认、带新问题的消息。

---

## 提炼逻辑

与 v1 相同，硬过滤原则不变：

- **Project Conventions**：用户纠正做法 / 确认非显而易见的选择 / 明确技术或命名决策
- **Workflow Preferences**：要求特定步骤 / 拒绝某种行为 / 同一模式 ≥ 2 次

模糊信号跳过，一次性上下文永远不是约定。

---

## 写入规则

**目标路径：** `~/.claude/skills/<项目名>-skill/SKILL.md`  
**禁止写入：** `~/.claude/projects/.../memory/`（memory 系统与 skill 系统相互独立）

```
1. 文件不存在 → 用 Write 工具创建完整文件
2. 文件存在，新增后 ≤ 180 行 → Read + 合并去重 + Write
3. 文件会超过 180 行 → 拆分：
   - SKILL.md 保留总览（含链接）
   - 内容移至 reference/conventions.md 和 reference/workflow.md
   - reference/ 只允许一层深，不允许嵌套
```

---

## 确认流程

写入前展示预览，等待用户确认：

```
Extracted the following, ready to [create | append to | split]
`~/.claude/skills/<项目名>-skill/SKILL.md`:

**Project Conventions (new)**
- <item>

**Workflow Preferences (new)**
- <item>

Shall I write the file now?
```

- 确认 → Write 工具直接写入，聊天中不输出原始内容
- 拒绝 → 静默跳过
- 无可提炼内容 → 跳过确认，静默跳过

---

## 文件结构

```
~/.claude/skills/<项目名>-skill/
  SKILL.md                   # 主文件（≤ 180 行）
  reference/
    conventions.md            # 拆分后的约定（可选）
    workflow.md               # 拆分后的偏好（可选）

skills/session-to-skill/      # 本 skill 自身
  SKILL.md                    # 88 行，精简结构
  reference/
    compact-reminder.md       # /compact 提示模板
```

---

## 不在范围内（v2）

- 不读取 JSONL 历史转录（仅使用当前对话上下文）
- 不做语义去重（纯文本匹配）
- 不自动触发（仍需信号词或用户确认）

---

## 未来版本方向（备忘）

- **v3**：读取 JSONL 转录，支持跨会话内容合并
- **v3**：语义相似度去重，而非纯文本匹配
