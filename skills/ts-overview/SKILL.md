---
name: ts-overview
description: >
  阶段一：把产品 PRD 翻译为开发契约 —— 产出后端概设（主线契约）+ 前端概设 + UI 原型（真 te-* 组件组合的 Vue 3 + TS 单文件组件，
  落项目根 prototype/）。三件产物经用户确认后，方可进入详细设计。
user-invocable: true
agent_created: true
when-to-use: "产品 PRD 就绪、需要产出阶段一产物（后端概设 + 前端概设 + UI 原型）时；或 ts-design 报出阶段一产物缺失时。"
---

# Goal（目标）

> **路径约定**：本技能内所有以 `references/` 开头的路径，均相对于本 SKILL.md 所在目录（技能根）；文中出现的 `xxx-standard.md` 等规范文件，全文见 `references/rules/` 下的同名文件。

把 PRD 的**业务语言**翻译为**开发契约**，产出阶段一三件产物：

| 产物 | 形态 | 落位 |
| --- | --- | --- |
| **后端概设** | `overview-be-*.md`，定稿主线契约（领域模型 / 状态机 / 数据字典 / 接口契约 / 权限矩阵 / 消息事件） | `archive-spec/product/` |
| **前端概设** | `overview-fe-*.md`，引用后端契约，落地页面与路由、API 模块 | `archive-spec/product/` |
| **UI 原型** | 真 `te-*` 组件组合的 Vue 3 + TS 单文件组件（`.vue`），可构建可渲染 | **项目根 `prototype/`** + 交接件 `_notes.md` 归档 `ui-*/` |

**三件产物经用户确认后，方可进入详细设计（ts-design）。**

---

# Role（角色）

资深全栈工程师兼系统架构师。职责是把业务需求翻译成前后端都"接得住"的契约。

> **Design First，契约优先，锚点一致。**

**本阶段禁止编写 `src/` 下的生产代码。**

---

# 执行模式（Execution Mode）

阶段一**不是单线程顺序执行**，而是「主线程分派 + 并行产出 + 统一确认」：

- 主线程基于 PRD **并行分派前端、后端两个子 agent** 生成概设（用 Agent 工具，`subagent_type: general-purpose`），各按模板产出
- **UI 由独立 UI 子 agent** 产出原型；产出前**先读**三层规范（契约 → 品牌 → 按屏型取工艺）
- 三件产物**互不为输入**，只共同锚定 PRD 的 **S-xx 编号**；确认时按 S-xx 对齐
- 所有产物落位后**停止并等待用户确认**，确认前不进入 ts-design
- 当前环境不支持子代理时，由主线程顺序产出，行为等效（S-xx 对齐照旧）

> 本 Skill 内容**自包含**：子代理基于仓库现状自行确定 PRD 与规范，不依赖主对话上下文。

---

# When to Use（适用场景）

- PRD 就绪，需要把它转成开发契约时
- `ts-design` 门禁报出「阶段一产物缺失」时（回到本阶段补齐）
- 需求涉及多角色 / 状态流转 / 接口对接，需要先对齐前后端契约时

**不需要**独立概设：PRD 已明确、无状态流转、无多角色差异的极简单需求，可直接进入详细设计（须用户确认）。

---

# Required References（前置规范）

| 用途 | 文件 |
| --- | --- |
| **完整流程规范（必读）** | `references/rules/overview-standard.md` —— 必要章节、编写边界、主线/支线机制、归档命名、质量检查清单 |
| 后端概设模板 | `references/templates/overview-be.md` |
| 前端概设模板 | `references/templates/overview-fe.md` |
| PRD 骨架（可选起点） | `references/templates/prd-template.md` |
| **UI 原型契约（必读）** | `references/rules/ui-prototype-standard.md` —— 产出形态、三步结构分析、五态与数据接入、样式边界、区域→组件映射、命名与落位 |
| 品牌观感 | `references/design-systems/tiansu-web/DESIGN.md` |
| 工艺（按屏型取用） | `references/rules/hifi-craft.md` + `references/assets/open-design/craft/` |
| 原型运行壳 | `references/assets/prototype-sandbox/`（拷进 `<项目根>/prototype/`，用项目的 `node_modules` 跑） |

---

# Workflow（工作流程）

## Step 0：输入校验

- [ ] PRD 存在（`archive-spec/product/prd-*.md` 或用户提供）
- [ ] PRD 含 **S-xx 场景编号脊椎**——缺则先补。**编号即脊椎**：前后端概设与 UI 原型都对着它做支线
- [ ] 确认版本号 / 迭代号（沿用 PRD 的，不另开）

## Step 1：并行产出三件产物

**后端概设**（子 agent 1）—— 按 `references/templates/overview-be.md`：
主线契约定稿（领域模型 / 状态机 / 数据字典 / 接口契约 / 权限矩阵 / 消息事件）+ 按 S-xx 的后端支线。**只写契约，不写表结构。**

**前端概设**（子 agent 2）—— 按 `references/templates/overview-fe.md`：
引用后端契约（不重复定义、不自造字段）+ 按 S-xx 的页面与路由、API 模块清单。**不写组件级布局与视觉。**

**UI 原型**（子 agent 3，独立）—— 从 PRD 的 S-xx 直接推导页面：
- 产出前必读：契约（`ui-prototype-standard.md`）→ 品牌（`DESIGN.md`）→ 按屏型取工艺（`craft/`），顺序即注入优先级
- 产物是 `.vue`（真 `te-*` 组件组合），落**项目根 `prototype/`**，运行壳拷自 `references/assets/prototype-sandbox/`
- **必须真实构建并看过渲染**（`cd prototype && npx vite build`）；空白页 / 半截页不算通过
- 组件 API 用 `ts-components` 核实，不凭记忆写 Props

## Step 2：S-xx 对齐核对

- 以后端概设 §2.4 定稿为准，对齐前端概设 §2 接口清单
- 前端概设 §3.1 页面清单 与 UI 原型页面 按 S-xx **双向核对**，不一致回到 PRD 判定
- 不动后端主线；纯规则 / 无页面场景 UI 留空说明

## Step 3：落位与归档

```
archive-spec/product/
    overview-be-V<MAJOR>.<MINOR>.<PATCH>_I<ITERATION>_<描述≤6字>.md
    overview-fe-V<MAJOR>.<MINOR>.<PATCH>_I<ITERATION>_<描述≤6字>.md
    ui-V<MAJOR>.<MINOR>.<PATCH>_I<ITERATION>_<描述≤6字>/_notes.md

<项目根>/prototype/
    Sxx_<页面名>.vue                （真 te-* 组件组合，可构建可渲染）
    index.html / main.ts / vite.config.ts / tsconfig.json   （运行壳）
```

- 原型**只有一份**：归档里不存 `.vue` 副本，可运行的那份才是真相
- 命名：场景号两位补零 + 下划线（`S01_公告列表.vue`），**不用**连字符写法
- `prototype/` 写进项目 `.gitignore`

**归档后刷新跨项目索引**（约 20 秒）：

```bash
bash D:/workspace/company/design-workspace/gen-index.sh
```

`archive-spec/product/` 下的 `overview-be-*` / `overview-fe-*` / `ui-*/` 是索引「概设」列的来源。不重跑，`design-workspace/INDEX.md` 就不知道本次产出 —— 索引只读文件名、不读内容（绕开亿赛通加密），不会自己更新。

## Step 4：停止并等待确认 ⛔

**产物落位后立即停止，不进入 ts-design。**

- 向用户呈现三件产物的路径 + S-xx 对齐结论
- **等待用户明确确认**后，方可进入详细设计

---

# 门禁（Hard Gate）

- [ ] PRD 存在且含 S-xx 脊椎
- [ ] 后端概设 + 前端概设已落位并归档
- [ ] 有页面场景时 UI 原型已产出、**已真实构建渲染过**
- [ ] 三件产物按 S-xx 对齐完成
- [ ] **已重跑 `gen-index.sh`，`design-workspace/INDEX.md` 的「概设」列为 ✓**
- [ ] 用户已确认

**任一未满足 → 不得进入 ts-design。**

---

# 自检清单

逐项对照 `references/rules/overview-standard.md` 的质量检查清单（后端概设 / 前端概设 / UI 产出三组），全部勾选后方可提交用户确认。

---

# Success Criteria（完成标准）

- 三件产物齐全、归档命名符合规范、版本/迭代与 PRD 一致
- S-xx 锚点在四份产物间完全对齐
- UI 原型是**可运行的真组件原型**，不是静态图
- **未编写任何 `src/` 下的生产代码**
- 已等待用户确认
