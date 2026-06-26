# session-to-skill

**Language:** **中文** | [English](README.en.md)

一个 skill，在工作会话结束时自动从对话中提炼项目约定和协作偏好，并直接写入项目专属 skill
文件——无需手动编写，无需手动保存。

## 工作原理

会话结束时，当你说"谢谢"、"收工"、"done"等收尾语，Claude 会：

1. **扫描本次对话**，提炼明确出现的约定和偏好
2. **展示预览并询问确认**，待你确认后再写入
3. **直接写入**该项目的专属 skill 文件：`~/.claude/skills/<项目名>-skill/SKILL.md`

每个项目有且只有一个专属 skill 文件，绝不干扰其他项目的 skill。

## 示例

你在一个叫 `my-app` 的项目中结束了一次会话，其中说过"始终用具名导出"和"写代码前先给我看计划"
（说了两次）。你输入：*"谢谢，今天就这样了！"*

Claude 回复：

```
本次会话提炼到以下内容，准备新建 `~/.claude/skills/my-app-skill/SKILL.md`：

**Project Conventions（新增）**
- 始终使用具名导出，禁止 default export

**Workflow Preferences（新增）**
- 写代码前必须先给出计划（对话中确认 ≥ 2 次）

确认后我会直接写入文件。继续吗？
```

你回复"继续"后，Claude 直接将文件写入 `~/.claude/skills/my-app-skill/SKILL.md`，并确认：

```
不客气！这次会话很顺利。
已保存到 `~/.claude/skills/my-app-skill/SKILL.md`
```

下次会话结束时，只写入新增内容——已有的条目不会重复出现。

## 安装

### 方案一：一行命令（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/Shmilyol/session-to-skill/main/install.sh | bash
```

脚本会自动：

- 下载 skill 文件到 `~/.claude/skills/session-to-skill/`
- 将触发规则追加到 `~/.claude/CLAUDE.md`
- 检测是否已安装，避免重复写入

### 方案二：手动安装

```bash
# 第一步：clone 仓库
git clone https://github.com/Shmilyol/session-to-skill.git
cd session-to-skill

# 第二步：安装 skill
cp -r skills/session-to-skill ~/.claude/skills/

# 第三步：加入全局触发规则
cat CLAUDE.md.patch >> ~/.claude/CLAUDE.md
```

完成后，后续会话结束时 skill 会自动激活。

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
   → 直接写入完整文件，首次创建

2. 文件已存在，新增后 ≤ 180 行？
   → 读取现有内容，合并新条目（去重），写入

3. 文件会超过 180 行？
   → 拆分：SKILL.md 保留总览，内容移至 reference/conventions.md 和 reference/workflow.md

4. 写入 skill 文件后，自动注册到项目 CLAUDE.md：
   → 检查 <项目根目录>/CLAUDE.md 是否已有调用指令
   → 已存在 → 跳过（幂等）
   → 不存在 → 追加：
      ## Project Skill
      Invoke the `<项目名>-skill` skill at the start of every session using the Skill tool.
```

项目名取自 git 仓库名，或当前工作目录名。

## 触发条件

满足以下任一条件时激活：

- **会话结尾**：消息传达出**收尾意图**——用户表示今天到此为止、感谢本次协作或示意完成（`"done"` /
  `"谢谢"` / `"收工"` 等只是示例，含义相近的表达同样触发）；或主要任务全部完成、无新需求
- **主动请求**：用户明确要求**生成、提炼或总结**本次会话为 skill 文件（通过语义理解判断，不限于特定短语）
- **会话中途偏好信号**：消息传达出拒绝、约束或推荐**意图**时（通过语义理解判断，不依赖特定词汇；
  `不要` / `就可以` / `你应该` 等只是示例，含义相近的表达同样触发），Claude 会立即询问是否记录到项目 skill。
  此规则写在 `CLAUDE.md` 中，全局常驻，不依赖 skill 是否被加载

**不触发**：简短的回应、会话中途的普通确认、或意图是继续对话/提出新问题的消息。

## 兼容性

支持 Claude Code 及所有兼容 [Agent Skills](https://agentskills.io/specification) 规范的 agent（Codex
等）。

## 目录结构

```
skills/session-to-skill/
  SKILL.md                        # Skill 本体
  reference/
    compact-reminder.md           # /compact 时附加的提示模板
CLAUDE.md.patch                   # 追加到 ~/.claude/CLAUDE.md 的触发规则
docs/superpowers/
  specs/                          # 设计文档（v1）
  plans/                          # 实现计划
```

## 许可证

MIT