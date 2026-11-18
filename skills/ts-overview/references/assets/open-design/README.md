# references/assets/open-design — 内置 openDesign 资产

> **定位**：从 openDesign 搬运的**逐字内置文本资产**，供阶段一 UI 子 agent 组装工作上下文使用。
>
> **零运行依赖**：本目录只含 `.md` / `.txt` 文本，**不含**任何可执行代码、daemon、MCP、agent 运行时或模型 key。搬运层随插件发布，下游用户项目**无需安装 openDesign**。
>
> **上游版本**：openDesign `v0.21.1`（搬运时的版本；升版按下方「刷新方法」diff）。

---

## 资产三分：本仓库只有这里是「搬运层」

内置资产按**许可归属与更新节奏**分三处存放，本目录只是其中之一。改动时先确认改的是哪一层：

| 层 | 位置 | 内容 | 许可 | 刷新驱动 |
| --- | --- | --- | --- | --- |
| **搬运层** | `references/assets/open-design/`（本目录） | craft 全套 + 许可文件 | Apache-2.0（OD） / MIT（craft 上游） | 随 openDesign 升版 diff |
| **自编设计系统** | `references/design-systems/tiansu-web/` | DESIGN.md / tokens.css / manifest.json / USAGE.md / components.html / preview/ | 天溯自有 | 随 Te 主题（theme-chalk）刷新 |
| **自有契约** | `references/rules/ui-prototype-standard.md`、`references/rules/hifi-craft.md`、`skills/ts-frontend-design/`、`references/assets/prototype-sandbox/`（原型运行壳，天溯自有） | 原型契约 / 工艺清单 / 视觉生成入口 / 运行壳 | 天溯自有 | 独立演进，不随 OD 升版 |

> **为什么分开**：三者更新节奏不同。openDesign 升版只需 diff 搬运层；Te 主题改版只需重刷 `tokens.css`；契约与工艺清单作为天溯自有规范独立演进——互不牵连。

---

## 目录结构

```
references/assets/open-design/
├── README.md                     ← 本文件
├── LICENSES/
│   ├── LICENSE-OPEN-DESIGN.txt   ← openDesign 本体许可（Apache-2.0）
│   └── LICENSE-CRAFT.txt         ← craft 上游 refero_skill 许可（MIT）+ 出处
└── craft/                        ← 品牌无关 UI 工艺规则书（13 个 .md）
    ├── README.md
    ├── typography.md
    ├── typography-hierarchy.md
    ├── typography-hierarchy-editorial.md
    ├── color.md
    ├── anti-ai-slop.md
    ├── state-coverage.md
    ├── animation-discipline.md
    ├── accessibility-baseline.md
    ├── rtl-and-bidi.md
    ├── form-validation.md
    ├── laws-of-ux.md
    └── FUTURE_SECTIONS.md
```

---

## prototype-sandbox/ 是什么

`references/assets/prototype-sandbox/` 是阶段一 UI 原型的**运行壳**——原型是 `.vue`，得有人把它挂起来才能在浏览器里看。
壳由独立 UI 子 agent **拷进项目根 `prototype/`**（不是插件的运行时依赖），依赖用**项目自己的** `node_modules`：

```
<项目根>/prototype/
├── index.html / main.ts / vite.config.ts / tsconfig.json   ← 从本目录拷来
└── Sxx_页面名.vue                                          ← 原型（落位见契约 §3.2）
```

- 跑法：`cd prototype && npx vite`（构建 `npx vite build`）。
- 用项目的 `node_modules`，所以**组件库版本与项目一致**——「组件选型在阶段一被真实验证」这句话才成立。
- `prototype/` 加进项目 `.gitignore`，不进 git，不进生产构建。
- 使壳在项目 `node_modules` 下有意义的原因见契约 `references/rules/ui-prototype-standard.md` §3.2。

> **实测坑清单在 `prototype-sandbox/README.md` 末节**（无头截图、CSS 过渡不结束、`.tlws-form` 压塌等），
> 动手截图前先扫一眼。

---

## craft/ 怎么用

OpenDesign 靠 daemon 读 skill 前言的 `od.craft.requires` 自动注入 craft；**插件环境没有该机制**，改为**按屏型手工读入**——在 UI 产出/详细设计的 Step 0 声明本屏要读哪几本：

| 屏型 / 阶段 | 应读 craft | 说明 |
| --- | --- | --- |
| 生成任何界面 | `typography`、`color`、`typography-hierarchy` | 排版与配色纪律，HiFi 底线 |
| 营销页 / 落地页 / 品牌装饰强 | `anti-ai-slop` | P0 规则（蓝紫主色、双色 hero 渐变、emoji 当图标等） |
| 有状态的 UI（表格 / 表单 / 列表 / 多屏） | `state-coverage` | 五态覆盖，与契约 §5 一致 |
| 带动效 | `animation-discipline` | 进入 200ms / 退出 140ms，禁 ease-in |
| 任何可交互 UI | `accessibility-baseline`、`form-validation` | 焦点可见、对比度、键盘可达 |
| 中英文混排 / 正文表面 | `typography-hierarchy-editorial`、`rtl-and-bidi`（如有 l10n） | CJK 行高纪律见契约 §4 |

> **token 映射（重要）**：craft 正文沿用了 OpenDesign 的通用语义 token 举例（`var(--accent)` 等），那是**语义占位**，不是要求引入 `--accent`。落到天溯体系时：**原型也不填 `:root`、不用 `--p-*`**——视觉一律来自组件库主题（`--te-*` 由 `ts-web-package` 提供），实现同理，用 `var(--te-*)` 或 Te 组件 props（契约 `references/rules/ui-prototype-standard.md` §7）。

> **层级关系**：craft 讲**品牌无关的工艺通用规则**（全大写必 ≥0.06em 字距等），落在 `references/design-systems/tiansu-web/DESIGN.md`（品牌观感）与 `references/rules/ui-prototype-standard.md`（契约）**之上**，三者互补；冲突时以契约与 DESIGN.md 为准。

---

## 刷新方法（openDesign 升版时）

1. 取新版本 openDesign 仓库，diff 其 `craft/` 与本目录 `craft/`：

   ```bash
   diff -r <open-design-new>/craft references/assets/open-design/craft
   ```

2. 逐条确认差异是**上游真实变更**后再同步；若上游改动涉及新增/删除文件，同步更新本 README 的目录结构与上游版本号。
3. 若上游 `craft/README.md` 的 Attribution 小节有变化（出处、许可、版权行），同步更新 `LICENSES/LICENSE-CRAFT.txt`。
4. 同步后按 `references/rules/ui-prototype-standard.md` §11「工艺」组自检，确认既有引用未失效。

---

## 许可与合规

- **openDesign 本体**（Apache-2.0）：见 `LICENSES/LICENSE-OPEN-DESIGN.txt`。
- **craft 内容**：改编自 MIT 许可的 [refero_skill](https://github.com/referodesign/refero_skill)（© Refero Design），再由 OpenDesign 编辑；出处与许可全文见 `LICENSES/LICENSE-CRAFT.txt`，**该归属声明同时保留在 `craft/README.md` 内**（随副本逐字搬运）。
- 未搬运：openDesign 的 daemon / MCP / agent 运行时 / better-sqlite3 等任何运行依赖，亦未搬运其 151 个第三方品牌设计系统。
