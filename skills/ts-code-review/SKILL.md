---
name: ts-code-review
description: "对已实现代码进行 Code Review，检查规范遵循、代码质量、潜在问题，输出分级审查报告。"
user-invocable: true
agent_created: true
when-to-use: "编码完成、交付前，或用户明确要求 Code Review 时。"
---

# Goal（目标）

> **路径约定**：本技能内所有以 `references/` 开头的路径，均相对于本 SKILL.md 所在目录（技能根）；文中出现的 `xxx-standard.md` 等规范文件，全文见 `references/rules/` 下的同名文件。

对已编写的代码进行全面审查，发现规范违反、逻辑错误和潜在风险，输出可执行的改进建议。

**本阶段不修改代码，只发现问题。**

---

# Role（角色）

你是一名资深前端审查者（Staff Engineer）。职责是发现代码问题并提供可执行的改进建议，不是重写代码。

> **规范优先、质量优先、可维护性优先。**
> **以怀疑者视角主动证伪：假设代码存在缺陷去验证，而非默认正确。**

---

# When to Use（适用场景）

- 编码完成后
- 提交 PR 前
- 用户要求 Code Review
- 重构后验证

---

# 执行模式（Execution Mode）

本 Skill 默认以**独立子代理（subagent）执行**：用 Agent 工具（`subagent_type: general-purpose`）
启动一次隔离子任务，把本 SKILL.md 全文与待审查范围一并作为任务提示传入。

- 主线程仅负责触发审查并转述结果，不参与审查细节
- 审查在隔离 subagent 内一次性完成：读取规范 → 确定范围 → 逐文件审查 → 对照设计文档 → 输出报告
- 主线程收到报告后向用户展示，**等待用户确认**，确认前不进入修改阶段
- 当前环境不支持子代理时，由主线程内直接执行本流程，行为等效

> 本 Skill 内容**自包含**：subagent 基于仓库现状自行确定范围与规范，不依赖主对话上下文。

---

# Required References（前置规范）

- 设计文档：`archive-spec/design/` 下对应的设计文档
- 规范文件：`references/rules/coding-standard.md`、`references/rules/vue-standard.md`

---

# Workflow（工作流程）

## Step 1：确定审查范围（自包含）

subagent 独立确定范围，不依赖主对话上下文：

- 优先使用调用时传入的范围（模块 / 目录 / 文件清单）
- 未指定时，通过命令获取未评审变更：
  - `git status` / `git diff` — 工作区未提交变更
  - `git diff HEAD~1..HEAD` — 最近一次提交的变更
  - `git log --name-only --oneline -3` — 最近变更文件清单

---

## Step 2：逐文件审查

对每个文件，按以下维度检查：

### 类型检查

- 是否存在 `any`？
- Props/Emits/Expose 是否带类型？
- API 函数的返回类型是否正确（`CommonResponseType<T>`）？

### 规范检查

- 文件命名是否符合规范（camelCase / kebab-case）？
- 是否使用了 `el-` 前缀组件？
- Import 顺序是否正确（第三方 → @/ → 相对路径）？
- 组件选择是否遵循优先级？
- 代码中组件名 / Props 是否通过 `ts-components` skill 核实为组件库真实 API？

### 代码质量

- 是否存在 `console.log` / `debugger`？
- 是否存在魔法数字？
- 是否存在重复代码？
- 函数是否过长（> 100 行）或嵌套过深（> 3 层）？

### 逻辑检查

- 组件的 Loading / Empty / Error 状态是否覆盖？
- API 调用是否通过 `request`（非直接 axios）？
- 删除/提交是否有 loading 防重复？
- 操作成功/失败是否有 message 提示？

### 影响检查

- 是否修改了无关文件？
- 是否存在 Breaking Change？
- 是否引入了不必要的依赖？

---

## Step 3：对照设计文档

将实现与设计文档对比：

- 文件清单是否与设计一致？有无遗漏或多余？
- 组件结构是否与设计一致（列表/form/detail 分别存在）？
- API 函数签名是否与设计一致？

---

## Step 4：输出审查报告

输出到 `archive-spec/reviews/`，命名遵循 references/hard-gate.md「产物归档」：

```
review-code-V<MAJOR>.<MINOR>.<PATCH>_I<ITERATION>_<描述(≤6字)>.md
```

报告结构遵循本 SKILL 内联清单（无独立模板文件），至少包含：
- 总体结果
- 审查的文件清单
- 问题列表（分级）
- 与设计文档的一致性检查
- 最终建议

---

## Step 5：返回结果 ⛔

**审查完成后立即停止，不修改代码。**

- 报告写入 `archive-spec/reviews/` 后，将**报告路径 + 总体结论**作为最终结果返回
- 主线程收到后向用户展示，**等待用户确认**；仅在用户确认后，方可进入修改阶段

---

# Severity（问题等级）

| 等级 | 含义 | 示例 |
|------|------|------|
| **Critical** | 必须修复 | `any` 类型、`console.log`、`el-` 组件、Breaking Change |
| **Major** | 建议修复 | 魔法数字、超长函数、缺少状态覆盖、Import 顺序不对 |
| **Minor** | 建议优化 | 变量命名、注释缺失、可提取的重复逻辑 |
| **Suggestion** | 优化建议 | 性能优化、更好的写法 |

---

# Review Gate（审查门禁）

- [ ] 全部文件已审查
- [ ] 无 Critical Issue
- [ ] Major Issue 已列出
- [ ] 与设计文档一致
- [ ] 审查报告已生成

**存在 Critical Issue → 修复后重新审查。**
