---
date: 2026-06-26
change: All trigger conditions — keyword/phrase lists → semantic intent detection
files:
  - skills/session-to-skill/SKILL.md
  - README.md
  - README.en.md
---

# 变更：所有触发条件从文本匹配改为语义意图识别

## 背景

上一版（见 `2026-06-26-intent-based-trigger-detection.md`）仅将 Section 3"Mid-session preference
signal"改为意图驱动。用户指出 Section 1、Section 2 和"Do NOT trigger on"同样枚举了固定词表，
存在同样的局限：LLM 有语义理解能力，不应依赖词面匹配。

## 变更内容

### Section 1 — End-of-session

| 前 | 后 |
|----|-----|
| 列举 `done` / `thanks` / `谢谢` / `收工` / `完成了` 等固定收尾词 | 描述**收尾意图**：用户表示今天到此、感谢本次协作或示意完成；例子仅作参考 |

### Section 2 — Explicit request

| 前 | 后 |
|----|-----|
| 列举 `generate skill` / `生成 skill` / `总结一下` 等固定短语 | 描述**生成/提炼/总结 skill 的意图**；通过语义判断，不限于特定短语 |

### Do NOT trigger on

| 前 | 后 |
|----|-----|
| 列举 `嗯` / `ok` / `好` 等具体词 | 描述**继续对话或提新问题的意图**；不触发条件以意图而非词面界定 |

## 设计原则

所有触发条件统一为：**意图描述 + 说明性示例**。示例的作用是帮助 LLM 理解意图类型，
不是穷举匹配列表。等义或近义表达应与列出的示例具有同等触发效力。

## 影响文件

- `skills/session-to-skill/SKILL.md`（开发仓库 + `~/.claude/skills/session-to-skill/` 同步）
- `README.md`
- `README.en.md`
