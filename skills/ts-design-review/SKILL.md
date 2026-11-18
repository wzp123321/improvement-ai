---
name: ts-design-review
description: "对详细设计文档（DDD）进行全面评审，验证设计质量、架构一致性、风险及可实施性。设计评审阶段禁止编写任何业务代码。"
user-invocable: true
agent_created: true
when-to-use: "详细设计文档已生成，进入编码前必须执行设计评审时。"
---

# Goal（目标）

> **路径约定**：本技能内所有以 `references/` 开头的路径，均相对于本 SKILL.md 所在目录（技能根）；文中出现的 `xxx-standard.md` 等规范文件，全文见 `references/rules/` 下的同名文件。

对设计文档进行全面评审，输出分级问题与改进建议，判定是否允许进入开发。

**本阶段禁止编写任何生产代码。**

---

# Role（角色）

你是一名资深系统架构师（Staff Engineer）。职责是审查设计质量，不是重新设计。

> **Architecture First、Correctness First、Quality First。**

---

# When to Use（适用场景）

设计文档完成后、开发前，必须执行本 Skill。可跳过范围见 `references/hard-gate.md`「三级判定（唯一权威）」表（**须经用户确认后**方可跳过）；跳过后按 `ts-implement` 技能 Step 0 的**例外分支**执行。

---

# 执行模式（Execution Mode）

本 Skill 默认以**独立子代理（subagent）执行**：用 Agent 工具（`subagent_type: general-purpose`）
启动一次隔离子任务，把本 SKILL.md 全文与待评审的设计文档路径一并作为任务提示传入。

- 主线程仅负责触发评审并转述结果，不参与评审细节
- 评审在隔离 subagent 内一次性完成：读取设计文档 → 逐项 Review → 输出评审报告
- 主线程收到报告后向用户展示，**等待用户确认**，确认前不进入开发阶段
- 当前环境不支持子代理时，由主线程内直接执行本流程，行为等效

> 本 Skill 内容**自包含**：subagent 基于仓库现状自行确定设计文档与规范，不依赖主对话上下文。

---

# Required References（前置规范）

- 设计文档：`archive-spec/design/` 最新版本
- 规范文件：`references/rules/design-standard.md`、`references/rules/design-review.md`、`references/rules/coding-standard.md`、`references/rules/vue-standard.md`
- 原型契约：`references/rules/ui-prototype-standard.md`（核对 §9.1 区域→组件映射、§5 五态与数据接入、命名落位 §3.2）
- 视觉纪律：`references/design-systems/tiansu-web/DESIGN.md` + `references/rules/hifi-craft.md`（评审页面设计的观感与反 AI 味）

---

# Workflow（工作流程）

## Step 1：确定评审对象（自包含）

subagent 独立确定评审对象，不依赖主对话上下文：

- 通过 `ls archive-spec/design/` / `git status` 确定最新设计文档（`archive-spec/design/design-*.md` 中最新的一个）
- 同步读取对应阶段一产物（后端概设 `overview-be-*.md` + 前端概设 `overview-fe-*.md` + **`<项目根>/prototype/` 下的原型 `.vue`** 及其交接件 `archive-spec/product/ui-*/_notes.md`），作为范围核对基准
- 确认设计文档：章节完整、使用标准模板、无缺失

---

## Step 2：阶段一产物与范围 Review

- 阶段一产物理解是否正确？有无遗漏或歧义？
- In Scope / Out of Scope 是否明确合理？
- 是否存在范围蔓延？

---

## Step 3：当前状态与复用 Review

- 是否分析了现有实现？
- 是否列出了可复用模块、组件、API、Store？
- 是否优先复用已有能力？是否存在重复设计？

---

## Step 4：方案 Review

对照 ts-design SKILL.md **Step 1（分析现状）与 Step 2（设计方案）** 的产出逐项检查：

- **概设落实**：设计文档是否**逐项落实阶段一产物**（概设契约 + `<项目根>/prototype/` 原型的区域→组件映射 → 组件级布局；是否写明原型的晋升目标 `src/views/<module>/index.vue`），每项设计有阶段一产物依据，无阶段一外新增；原型 `_notes.md` 的「未决问题」是否逐条给出结论

| 维度 | 检查点                                                                                                                                      |
| ---- | ---------------------------------------------------------------------------------------------------------------                             |
| 架构 | 分层是否合理、模块职责清晰、无循环依赖、符合项目分层模式                                                                                    |
| API  | 是否符合 `index.api.ts` + `index.ts` 标准、统一 POST via `request`、URL 前缀 `/sec/{moduleName}/`、类型引用正确                             |
| 数据 | Entity/DTO/Store 是否合理、是否不必要地新增 Store                                                                                           |
| UI   | 组件选择是否遵循优先级、组件名/Props 是否通过 `ts-components` skill 核实为组件库真实 API、是否覆盖 Loading/Empty/Error、Dialog 交互是否完整 |
| 流程 | Mermaid 时序图是否完整、是否覆盖所有交互场景                                                                                                |

---

## Step 5：决策与假设 Review

- 设计决策是否包含 5 维度对比 + 架构影响 + 演进路径？是否至少 1 个替代方案？
- 设计假设是否列出？每项是否说明失效后果？
- 方案选择理由是否充分？

---

## Step 6：影响与风险 Review

- 影响范围是否覆盖 8 个维度（Module/API/Database/Store/UI/Config/CI/CD/Documentation）？
- 风险分析是否覆盖 Breaking Change/Compatibility/Performance/Security/Data Migration/Technical Debt？
- **每项风险是否有解决方案？**

---

## Step 7：实施与验收 Review

- 实施策略分 Phase 是否合理？排序理由是否充分？
- 任务拆分是否可独立开发/测试/Review？
- 验收标准是否可验证/可测试/可量化？
- 测试方案是否覆盖正常/异常/边界/回归？

---

## Step 8：输出评审报告

参照 `references/templates/design-review.md` 模板生成报告，不得修改模板结构。

输出目录与命名遵循 references/hard-gate.md「产物归档」章节规范：

- 目录：`archive-spec/reviews/`
- 命名：`review-design-V<MAJOR>.<MINOR>.<PATCH>_I<ITERATION>_<描述(≤6字)>.md`

---

## Step 9：返回结果 ⛔

**评审完成后立即停止，不编写代码、不修改设计、不修改源码、不进入开发。**

- 报告写入 `archive-spec/reviews/` 后，将**报告路径 + 总体结论**作为最终结果返回
- 主线程收到后向用户展示，**等待用户确认**；仅在用户明确确认后，方可进入 ts-implement 阶段

---

# Review Principles（评审原则）

- 所有问题必须说明**为什么不好 + 如何改进**
- 不得仅说"不好"，必须给出可执行建议
- 优先关注架构一致性和模式匹配，而非个人偏好
- 以**怀疑者视角**主动证伪：假设设计存在缺陷去验证，而非默认正确

---

# Severity（问题等级）

| 等级           | 含义                                                               | 处理                       |
| -------------- | ------------------------------------------------------------------ | -------------------------- |
| **Critical**   | 架构错误、Breaking Change、安全/数据风险、自由发挥引入不存在的模式 | 必须修改，**禁止进入开发** |
| **Major**      | 模块职责不清、API 不统一、任务过大、测试不足                       | 建议修改                   |
| **Minor**      | 命名、描述、格式                                                   | 建议优化                   |
| **Suggestion** | 优化建议                                                           | 不影响开发                 |

---

# Review Gate（评审门禁）

- [ ] Review 已完成
- [ ] 设计文档已逐项落实概设契约（无概设外新增）
- [ ] 无 Critical Issue
- [ ] Major Issue 已确认
- [ ] 风险可接受
- [ ] 报告已返回主线程（用户确认由主线程完成）

**任一未满足 → 禁止进入开发。**

---

# Success Criteria（完成标准）

- 全部章节已检查
- 架构一致性与规范一致性已验证
- 风险与兼容性已评估
- 评审报告已生成
- **未编写任何生产代码**
