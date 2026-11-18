---
name: ts-design
description: "根据阶段一产物（后端概设 + 前端概设 + UI 原型 Vue SFC）逐项落实生成详细设计文档。用户确认前不允许编写任何业务代码。"
user-invocable: true
agent_created: true
when-to-use: "阶段一产物（前端概设 + 后端概设 + UI 原型）已确认，需要输出详细设计文档（DDD）时。"
---

# Goal（目标）

> **路径约定**：本技能内所有以 `references/` 开头的路径，均相对于本 SKILL.md 所在目录（技能根）；文中出现的 `xxx-standard.md` 等规范文件，全文见 `references/rules/` 下的同名文件。

根据阶段一产物（概设）**逐项落实**，生成完整、可评审、可实施的详细设计文档。**禁止编写生产代码。**

---

# Role（角色）

资深系统架构师。从全局视角审视需求，在多个可行方案中做最优权衡，保证设计的一致性、可扩展性、可维护性。

---

# ⛔ 强制门禁（Hard Gate）

遵循 references/hard-gate.md「强制门禁 — 详细设计门禁」。**阶段一产物不存在 → 立即停止，提示先完成阶段一产物校验。**

---

# Workflow（工作流程）

## Step 0：准备（必做）

- [ ] 已读 `references/rules/design-standard.md`、`references/rules/coding-standard.md`、`references/rules/vue-standard.md`
- [ ] 已读 `references/rules/ui-prototype-standard.md`（原型契约：区域→组件映射 §9、五态与数据接入 §5、样式边界 §7、`_notes.md` §10、命名与落位 §3.2）——**§2.4 读 `<项目根>/prototype/` 原型落实组件级布局的依据**
- [ ] 已读 `references/design-systems/tiansu-web/DESIGN.md`（Te 观感纪律），并按屏型取 `references/assets/open-design/craft/` 对应维度
- [ ] 已读阶段一产物（后端概设 `overview-be-*.md` + 前端概设 `overview-fe-*.md`，均在 `archive-spec/` 下；**`<项目根>/prototype/` 下的原型 `.vue`（有页面场景时；不存在则停止）**，其交接件是 `archive-spec/product/ui-*/_notes.md`），**并以阶段一产物为唯一需求来源；详细设计据此逐项实现概设契约与 UI 原型**
- [ ] 设计涉及组件时，**调用 `ts-components` skill**（Skill tool / `/ts-components`），按其流程执行 `tsweb info <组件名> --format json` 获取准确 Props/Events/Slots，并输出组件使用与配置

## Step 1：分析现状

逐项确认，不做重复建设（**技术层**，承接阶段一产物的业务分析输出；详细设计根据概设实现，业务契约以概设为准，不偏离、不新增概设外内容）：

- 已有功能/模块？可复用组件？相关 API/Store/类型？
- 现有架构分层与模块依赖？同类型模块的设计参考？
- 输出：**可复用清单** + **潜在冲突** + **架构一致性评估**

> 代码结构、可复用模块/组件/API/Store、架构分层与依赖均为本阶段职责；业务功能关系已在阶段一分析，此处不重述。

## Step 2：设计方案

**设计方案逐项落实阶段一产物**：概设契约（后端概设 §2 领域模型 / 状态机 / 数据字典 / 接口契约 / 权限 / 消息事件 + 前端概设 §3 页面与路由 / API 模块）+ `<项目根>/prototype/` 原型（`.vue`，区域→组件 / 交互 / 状态覆盖）在设计文档中实现为具体方案。设计文档的每一项都应在阶段一产物中有依据；超出阶段一范围的，回到阶段一确认后再设计，禁止自行补全。

### 2.1 架构与数据流

- 分层视图（View → State → API → Types），禁止循环依赖和跨层调用
- 数据流链路（API → Store → Component），标注每环数据形态变化
- 模块职责单一，组件契约明确（Props/Events/Slots）

### 2.2 目录与文件

新增/修改/删除的文件列表。

### 2.3 API 设计

参考 `src/apis/` 下现有模块，统一 POST + `request` 调用。类型定义（ListRow/QueryParams/FormData）遵循 `vue-standard.md`。

### 2.4 页面设计

**组件优先级**：`@tiansu/ts-web-package` → `@tiansu/element-plus` → `@/components/` → `modules/`（仅模块内）。禁止 `el-` 前缀。

**选择每个组件前**，调用 `ts-components` skill（Skill tool / `/ts-components`）核实组件真实 API（`tsweb info <组件名> --format json`），获取准确的 Props/Events/Slots。禁止凭记忆编造组件 API，禁止跳过 ts-components skill 直接运行裸 `tsweb` 命令。

每个页面**读 `<项目根>/prototype/` 下的原型（`.vue`）**，据此输出组件级布局图，标注具体组件名。原型已由真 `te-*` 组件组合，**区域→组件的映射就在模板里**（`references/rules/ui-prototype-standard.md` §9.1）——详设在这一映射之上补全 Props/Events/数据契约，**不重新选一遍组件**。

**指定晋升目标**：设计文档须写明每个原型 `prototype/Sxx_页面名.vue` 实现时落到哪个 `src/views/<module>/index.vue`，以及需要补齐的 `constant.ts` / `hooks/` / `modules/`（`references/rules/vue-standard.md` §3.1）。原型不是另写一遍的参考图，它就是该页的骨架。

> 对照依据：交接件 `archive-spec/product/ui-*/_notes.md`（§10）给出区域→组件映射、`--te-*` 使用、待替换占位与未决问题。原型里的组件是**已落地的选型**，Props/Events 仍须以 `ts-components` 核实为准。原型 `_notes.md` 的「未决问题」须在详设中逐条给出结论。

### 2.5 业务流程

Mermaid 时序图。

### 2.6 设计决策

关键设计点必须记录：最终方案、至少 1 个替代方案、5 维度对比（复杂度/可维护性/可扩展性/性能/风险）、选择原因。

## Step 3：风险评估

- [ ] 设计假设（每项说明失效后果）
- [ ] 影响范围（Module/API/Database/Store/UI/Config/CI/CD/Documentation，8 维，与 `references/rules/design-standard.md` §9 一致）
- [ ] 风险分析（**9 类，口径见 `references/rules/design-standard.md` §10**），每项有解决方案

## Step 4：实施计划

- [ ] 分 Phase，说明依赖关系
- [ ] 任务拆分：每个 Task 包含目标、文件、依赖、验收标准，可独立开发/测试/Review
- [ ] 验收标准：可验证、可测试、可量化

## Step 5：架构自检

聚焦不一致之处（一致则简要通过，不一致则说明理由）：

- 与现有设计模式一致？有无循环依赖或跨层调用？是否偏离概设契约？
- 是否引入不必要的抽象？是否预留合理扩展点？

## Step 6：输出文档并等待确认 ⛔

使用 `references/templates/design.md` 模板，输出至 `archive-spec/design/design-V<MAJOR>.<MINOR>.<PATCH>_I<ITERATION>_<描述≤6字>.md`。

生成文档时**一并给出命名建议**（版本号/迭代号/描述）。版本号基准遵循 references/hard-gate.md「产物归档」（以用户项目版本为基准）。

**生成后立即停止。** 禁止写代码、创建文件、生成测试。等待用户**一次确认命名与内容**；仅在用户明确回复确认后进入 **`ts-design-review`（设计评审）**——评审通过并再经用户确认后，方可进入 `ts-implement`。**不得由本步骤直接放行到编码。**

---

# Design Gate（设计门禁）

- [ ] 阶段一产物已归档且经用户确认
- [ ] **设计文档逐项落实概设**（每项设计有概设依据，无概设外新增）
- [ ] 已分析现状（可复用清单 + 冲突 + 架构一致性）
- [ ] 已完成架构/数据流/API/页面设计 + 设计决策（含 5 维度对比）
- [ ] 已完成假设/影响/风险分析（每项有方案）
- [ ] 已通过架构自检
- [ ] 已拆分任务（可独立开发/测试/Review）+ 验收标准
- [ ] 已生成设计文档（正确版本+目录）
- [ ] **已等待用户确认**
- [ ] **已提交 `ts-design-review` 并取得通过结论**（评审未通过前不得进入开发）
- [ ] **未编写任何生产代码**

**任一未满足 → 禁止进入开发。**
