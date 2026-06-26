---
date: 2026-06-26
change: Mid-session trigger detection — keyword list → semantic intent
files:
  - skills/session-to-skill/SKILL.md
  - README.md
  - README.en.md
---

# 变更：触发检测从关键词匹配改为语义意图识别

## 背景

原实现在 Section 3 "Mid-session preference signal" 中维护了一份固定关键词列表：

> `don't` / `never` / `only X` / `不要` / `别` / `就可以` / `不用` / `你应该` / `你需要` / `必须` ...

问题：LLM 本身具备语义理解能力，枚举词表会遗漏同义表达，且维护成本随语言增加而线性增长。

## 变更内容

将触发描述从"包含这些关键词"改为"表达这类意图"，词表例子降级为**说明性示例**，不再是穷举：

| 意图类型 | 语义描述 | 示例（仅作参考） |
|----------|----------|------------------|
| Rejection / exclusion | 用户表示不想要什么，或要停止某行为 | "don't", "never", "不要", "别" |
| Constraint / narrowing | 用户将范围限定到特定方式/工具/行为 | "only", "just X is enough", "就可以", "X 就行" |
| Directive / recommendation | 用户表示我应该/必须/总是做某事 | "you should", "always", "你应该", "你需要", "必须" |

## 影响

- `SKILL.md`：Section 3 触发逻辑描述更新
- `README.md` / `README.en.md`：触发条件说明同步更新
- 运行时行为：不变——触发时机相同，检测方式从词面匹配升级为语义理解
