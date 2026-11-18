---
name: ts-frontend-design
description: >
  生成高保真原型：由真 te-* 组件组合的 Vue 3 + TS 单文件组件，视觉与交互来自组件库主题而非手写 CSS。适用「独立视觉稿 / 页面原型的高保真生成 / 改版视觉预览」。
  禁止写任何生产代码，禁止绕过阶段一产物校验门禁与 ts-design 门禁。
user-invocable: true
agent_created: true
when-to-use: "需要独立出一版高保真视觉稿 / 页面原型 / 改版视觉预览时（阶段一 UI 原型默认由 ts-overview 产出，本技能是独立视觉稿入口）。"
---

# ts-frontend-design（高保真原型生成）

> **路径约定**：本技能内所有以 `references/` 开头的路径，均相对于本 SKILL.md 所在目录（技能根）；文中出现的 `xxx-standard.md` 等规范文件，全文见 `references/rules/` 下的同名文件。

> Adapted from Anthropic 官方 `frontend-design`（Apache-2.0，见本技能源说明），按天溯 Te 工程规范与
> `references/rules/hifi-craft.md` / `references/rules/ui-prototype-standard.md` 收敛。
>
> **2026-09-10 形态变更**：产物由「自包含 HTML」改为「**真 `te-*` 组件组合的 Vue 3 + TS SFC**」。
> 旧形态把组件选型推迟到阶段二，导致视觉稿与实现必然不一致；新形态下组件选型在阶段一完成并被真实渲染验证。
> 依据见 `references/rules/ui-prototype-standard.md` 卷首与 `archive-spec/product/ui-V3.1.0_I2_设备台账列表/_notes.md`。
>
> **2026-09-11 落位变更**：原型住进**项目根 `prototype/`**，用**项目的** `node_modules` 与 dev server 跑，
> 运行壳来自 `references/assets/prototype-sandbox/`。此前那个「与两个仓库都无关的临时 Vite 工程」是项目的仿制品——
> 自己重装一遍组件库、自己声明配置，于是「必须整体安装否则 `te-search` 静默消失」这类坑
> 恰好落在仿制品可能与真项目分叉的地方。`_notes.md` 仍归档到 `archive-spec/product/ui-*/`，**归档里不再存 `.vue` 副本**。

# Goal（目标）

从 PRD/设计文档/一句需求/参考图，产出一份**可直接构建渲染、能让人一眼认出是 Te 业务系统**的高保真原型——
由真 `te-*` 组件组合，视觉与交互来自组件库主题。并自检通过五态/权限/样式边界基线。
**本阶段禁止写任何业务代码（`src/`）。**

---

# ⛔ 触发门禁（先判定，不绕过）

**属于「必须走流程」的开发需求**（新增/修改/实现等功能变更，命中 references/hard-gate.md 三级判定）：
→ **立即停止**，先完成**阶段一**（产品 PRD → 前端概设 + 后端概设 + UI 原型，经用户确认）→ 再走 `ts-design`（设计，**消费**阶段一原型），本技能不替代设计文档。

本技能只在以下场景作为入口：

| 场景 | 行为 |
| --- | --- |
| 用户要「一版高保真视觉稿 / 美化现有界面 / 改版预览 / 单页视觉」且不进入实现 | ✅ 执行本流程，产物为设计稿 |
| 用户明确要一版视觉稿、但阶段一尚未产出原型（ts-design 默认只**消费**阶段一原型，不重新生成） | 作为工艺引擎被调用，遵守其输出契约（落位见 `references/rules/ui-prototype-standard.md` §3.2）；**仍须回阶段一确认后再入详设** |
| 用户要在实现流程里临时看某页「长什么样再定」 | ✅ 先出视觉稿供确认，确认后再回 ts-* 流程，**不据视觉稿直接写 Vue** |

产物落位：原型 `.vue` 落 **`<项目根>/prototype/`**（运行壳来自 `references/assets/prototype-sandbox/`，依赖用项目的 `node_modules`）；交接件 `_notes.md` 落 `archive-spec/product/ui-V<MAJOR>.<MINOR>.<PATCH>_I<ITERATION>_<描述≤6字>/`（落点与命名唯一口径见 `references/rules/ui-prototype-standard.md` §3.2）——有 S-xx 用 `Sxx_页面名.vue`，独立视觉稿（无 PRD/无 S-xx）直接用 `<页面名>.vue` 并在 `_notes.md` 标注。**绝不写 `src/`**（`prototype/` 在项目根，不在 `src/` 下）。

---

# Step 0：预读（必做）

- [ ] `references/rules/hifi-craft.md`（本流程的必查清单与反 AI 味 P0）
- [ ] `references/design-systems/tiansu-web/DESIGN.md`（Te 观感语法：组件语气 / accent≤2 / 密度 / 反 AI 味）
- [ ] `references/rules/ui-prototype-standard.md`（**必读**：产出形态与接入前提 §1、结构分析 §2、**落位 §3.2**、五态与数据接入 §5、**运行与验证 §6**、样式边界 §7、`_notes.md` §10）
- [ ] `references/assets/prototype-sandbox/`（**运行壳**：拷进 `<项目根>/prototype/`；末节的「已验证的实测坑」走之前先扫一眼）
- [ ] 涉及组件 API：走 `ts-components` skill，`tsweb info <组件> --format json` / `tsweb doc` / `tsweb demo` 核实；**禁止凭记忆**
- [ ] 按屏型补充 craft 维度：状态型 UI 读 `references/assets/open-design/craft/state-coverage.md`；有动效读 `references/assets/open-design/craft/animation-discipline.md`；可交互读 `references/assets/open-design/craft/accessibility-baseline.md` + `references/assets/open-design/craft/form-validation.md`；营销/装饰强读 `references/assets/open-design/craft/anti-ai-slop.md`
- [ ] 按屏型取配方：`references/recipes/*.md`。命中屏型时**先读配方再动手**（配方给该屏型的骨架、区域规格与专项自检）；未命中则只走本文件通用流程

> ⛔ **不再有 `tsweb design --format json` 取值的步骤**。旧形态下原型是手写 CSS，必须自己造出全套视觉值；
> 真组件形态下**颜色/字号/间距/圆角的唯一值源是组件库主题**，页面再造一套就是制造不一致。
> 仅当页面含**组件库覆盖不到的自定义区域**（图表、画布、大屏）时，才需要为该区定视觉值。

# 屏型配方（references/recipes/）

| 配方 | 屏型 | 文件 |
| --- | --- | --- |
| 列表管理页 | XX 列表 / XX 管理 / 查询页 / 增删改查（**中后台默认屏型**） | `references/recipes/list-page.md`（Te 原生） |
| 详情页 | XX 详情 / 明细 / 档案 / 单据查看 | `references/recipes/detail-page.md`（Te 原生） |
| 数据看板 | 管理后台 / 运营看板 / 分析驾驶舱 / 指标首页 | `references/recipes/dashboard.md` |
| 运维手册 | 服务手册 / on-call 指南 / SRE 文档 / 故障处置卡 | `references/recipes/runbook.md` |
| 财务报告 | 月/季/年度财报 / 经营分析 / P&L 汇报页 | `references/recipes/finance-report.md` |

> 配方是**该屏型的工艺知识**，不替代 `references/rules/ui-prototype-standard.md` 的契约（结构 / 命名 / 五态 / 自检）。
> 两者冲突时，以契约与 `references/design-systems/tiansu-web/DESIGN.md` 为准。

# Workflow

## 1. 理解输入（先于选视觉）

- 输入：PRD/设计文档、ASCII 布局 + 组件名、或参考图。参考图先按 `references/rules/ui-prototype-standard.md` §2 做三步结构分析（来源确认 / 区域划分 / 区域→组件；信息不足就**提问**，不假设）。
- 技术约束：目标视口、是否有现成组件/截图。
- 若仓库已有组件/已确认的 DESIGN 观感 → **以其为准**。

## 2. 结构分析（三步，先于动手）

拿到参考图 / 截图 / 已有页面时，按 `references/rules/ui-prototype-standard.md` §2 走三步：**来源确认 → 区域划分 → 区域→组件**。任一步信息不足就**提问**，不假设。

**不再做「六步视觉分析」**（视口栅格 / 字号层级 / 颜色角色）：真组件形态下视觉值由组件库主题决定，页面再推一遍只会推出与主题不一致的近似值。

**只有一种情况仍要定视觉方向**：页面含**组件库覆盖不到的自定义区域**（图表、画布、时间轴定制、大屏）。该区要能被一句话描述（数据密集企业 / 沉稳业务 / 紧凑运营…），并明确避开 AI 默认：蓝紫渐变、玻璃卡片、千篇一律 SaaS、超圆角、装饰 blob。

## 3. 画真实界面，不画海报

- 命中屏型配方（`references/recipes/`）时，**骨架与区域规格以配方为准**，不临时发明布局；未命中则按语义与业务惯用节奏自定。
- 逐区落到真组件上，把该有的控件、状态、表格、筛选做进去——**组件库提供的交互一律用组件本身，不自己搭一个像的**。
- 五态齐全（loading/empty/error/populated/edge），error 不等于 empty；**状态由数据驱动，不是模板里的假分支**。
- 真实文案与业务微文案（“开始跟进”优于“立即开始”）；数据未知则标“示例/待定”，不编造指标。示例数据须在页面上带标识。

## 4. 生成 Vue SFC 原型（组合纪律）

- **产物是 `.vue`**（Vue 3 + TS，`<script setup lang="ts">`），由真 `te-*` 组件组合。逐区选组件，选型经 `ts-components` 核实。落在 **`<项目根>/prototype/`**。
- **接入前提**（缺一不可，详见 `references/rules/ui-prototype-standard.md` §1）：
  1. 依赖 `@tiansu/ts-web-package`（≥2.0.0）；
  2. **整体安装组件库** `createApp(App).use(TsWebPackage)`——`te-tablebar` 内部按名取 `te-search`，只按需 import 会**静默**失去搜索框；
  3. 组件 API 经 `tsweb info` / `doc` / `demo` 核实，不凭记忆。
- **引法照抄项目**：沙箱 `main.ts` 里组件库与主题的引入路径、语言包、全局指令，照项目 `src/main.ts` 抄。另挑一套引法就失去了「验证项目里长什么样」这个唯一目的。
- **值源 = 组件库主题**。不填 `:root`、不用自定义前缀 `--p-*`、不抄 `tokens.css` 快照。需要主题变量时直接用 `--te-*` 运行时变量名。
- **数据接入**：列表/数据区走 `:request-api`，**不用静态 `:data`**。静态数据绕过 `useTable` 管线，会让操作列、分页、序号列**静默空掉**（依据见 `references/rules/ui-prototype-standard.md` §5.2）。用本地 mock 兑现 `{ data: { rows, total } }`，并让筛选**真实生效**。
- **状态**：loading / empty / error / populated / edge 五态齐全，error ≠ empty；「从未有数据」与「筛选后无结果」给**不同出口**。五态由变更 mock 返回驱动，不是模板里的假分支。
- **样式边界**（`references/rules/ui-prototype-standard.md` §7.2）：`<style>` 里**只有页面级布局**（区块排布、页面自插容器的排布、自建区域）。**不写颜色/字号/行高/圆角**去覆盖组件外观，**不用 `:deep()`** 进组件内部。
- **页面级布局经验**：`te-tablebar` 的 `#searchList` 槽位没有布局约定，插入的控件默认竖排铺满；横排要**包在自己的容器里**，不能 `:deep` 进去。
- 页面自写文本的 CJK 排版按 `references/rules/ui-prototype-standard.md` §4 数值；组件内部文本不归本阶段管。
- 自建区域的动效：曲线 `cubic-bezier(0.2,0,0,1)`、非跨屏 <500ms、动画不作唯一状态信号、默认处理 `prefers-reduced-motion`（`references/rules/ui-prototype-standard.md` §5.5）。

## 5. 打磨工艺

- 排版/布局/细节逐项过 `references/rules/hifi-craft.md`；组件语气与 density 对齐 DESIGN.md。
- **先检查有没有越界**：`<style>` 里出现色值、字号、圆角、`:deep()` → 删掉（`references/rules/ui-prototype-standard.md` §7.2）。这一条比任何打磨都优先。
- 一个能记住的细节：数字跳变、产品级微文案——但只在支持概念时加，且不因此覆盖组件外观。

## 6. 自检后交付 ⛔

- 对照 `references/rules/hifi-craft.md` §7 与 `references/rules/ui-prototype-standard.md` §11 自检清单逐项勾选（P0 反 AI 味 / 五态 / CJK 排版 / 对比度 / 焦点 / 样式边界）。
- **必须真实构建并渲染过**：拷 `references/assets/prototype-sandbox/` 到 `<项目根>/prototype/`，用**项目的** `node_modules` 起 dev server（`cd prototype && npx vite`）构建，并**看过截图**（`references/rules/ui-prototype-standard.md` §6）。空白页 / 半截页面 / 竖排塌掉的查询区都算没通过。`prototype/` 进 `.gitignore`，截图不进 git。
- 原型 `.vue` 落 `<项目根>/prototype/`；交接件 `_notes.md` 落 `archive-spec/product/ui-*/`，记录区域→组件映射、`--te-*` 使用、待替换占位（mock、演示脚手架、硬编码数据）、未决问题（含本次实测的组件库坑）——按 `references/rules/ui-prototype-standard.md` §10 的五个小节。
- **生成后停止并等待用户视觉验收**。验收通过后若要进实现 → 回到 ts-design（把原型固化为该页设计）或 ts-implement（原型**晋升**：移入 `src/views/<module>/index.vue`，按 `references/rules/vue-standard.md` §3.1 补齐 `constant.ts` / `hooks/` / `modules/`，接真 API，删演示脚手架），本技能不写 `src/` 生产代码。

---

# 源与归属

- 上游：Anthropic `frontend-design`（Apache-2.0）—— https://github.com/anthropics/skills/tree/main/skills/frontend-design
- 反 AI 味：refero_skill（MIT）→ `references/assets/open-design/craft/anti-ai-slop.md` / `references/rules/hifi-craft.md`
- craft 全文逐字搬自 openDesign `craft/`（v0.21.1），许可与出处见 `references/assets/open-design/LICENSES/`
- 本技能由 OpenDesign `frontend-design` 技能 按 tiansupowers 工程规范改写。
