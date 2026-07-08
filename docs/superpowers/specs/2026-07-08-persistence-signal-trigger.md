---
date: 2026-07-08
change: Generalize trigger condition 2 from phrase examples to a persistence-signal test; extend description to cover /compact and recap-only requests
files:
  - skills/session-to-skill/SKILL.md
  - README.md
  - README.en.md
---

# 优化：触发条件 2 从例句匹配改为持久化信号判据，description 补充 /compact 场景

## 问题

用户在另一个项目里说"你总结一下上下文的内容，我都让你注意了哪些事项"，本意只是想要一份聊天内的
回顾，但按 SKILL.md 原文，"总结一下"被列为触发条件 2 的示例短语，容易让判断标准变成关键词匹配，
而不是真正区分"要不要落盘"。同时 description 里"the user explicitly asks to generate or extract
a skill"这句本身就是粗筛门槛——如果一个边界请求在这一步就被判定为不像是"要生成 skill"，body 里
再细的逻辑也没有机会执行。

## 根本原因

两个层面都可能漏判：

1. **description（粗筛）**：决定 Claude 是否要调用这个 skill。原文完全没提 `/compact` 建议场景
   （触发条件 4），也没有为"回顾类请求也可能需要问一句要不要持久化"留出空间。
2. **触发条件 2（细判）**：原文拿两句具体例句当区分依据，容易被读成穷举列表，覆盖不到其他措辞。

## 解决方案

**SKILL.md 触发条件 2**：改为判断"持久化信号"——请求里有没有出现指向对话之外的词（文件、skill、
记住、保存、以后/下次自动加载），而不是只问"这次聊了什么"。没有持久化信号时，先给聊天内回顾，
再检查回顾内容本身是否就是约定/偏好，若是则事后问一句是否要顺便存成 skill；用户拒绝则本次会话不
再追问。

**description**：补充覆盖"用户要求回顾本次会话约定/偏好（即使只是普通总结请求）"和"即将建议
`/compact`"两种场景，让边界请求能先进入 skill 正文，由正文的持久化信号判断兜底，而不是在粗筛阶段
被过滤掉。

## 效果

- "总结一下…注意事项"这类边界请求会被正确识别为纯聊天回顾，不会被误判成需要立即写文件
- 回顾内容本身若确实是约定/偏好，Claude 仍会主动问一句要不要持久化，不会因为没匹配到固定短语而
  完全放弃这个机会
- `/compact` 建议场景现在也在 description 覆盖范围内

## 已更新文件

- `skills/session-to-skill/SKILL.md`：触发条件 2 改为持久化信号判据；description 补充
  /compact 场景与回顾类请求
- `~/self-skill/session-to-skill`（开发仓库）：对应 commit 已提交，未 push
- `README.md` / `README.en.md`：触发条件说明同步更新，新增 `/compact` 建议一条
