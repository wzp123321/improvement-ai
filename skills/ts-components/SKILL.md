---
name: ts-components
description: >
  当用户任务涉及天溯组件库 (ts-web-package) 时触发。触发条件： 代码中 import from '@tiansu/ts-web-package'、
  使用 Te 前缀组件名、 或明确提到天溯组件库。 不触发：用户吐槽组件库缺陷但不涉及代码修改、竞品对比讨论、等与组件使用无关的话题。
user-invocable: true
agent_created: true
when-to-use: "任务涉及天溯组件库 @tiansu/ts-web-package：代码中 import 该包、使用 Te 前缀组件名，或明确提到天溯组件库时。"
---

# 天溯组件库 CLI

> **路径约定**：本技能内所有以 `references/` 开头的路径，均相对于本 SKILL.md 所在目录（技能根）；文中出现的 `xxx-standard.md` 等规范文件，全文见 `references/rules/` 下的同名文件。
> **工具范围**：本技能只用于查询/生成天溯组件库相关信息，只允许执行 `tsweb` 与 `@tiansu/web-cli`（`npx @tiansu/web-cli`）相关命令。不要为完成本技能任务去读改项目业务代码或执行其他命令。

你可以使用 `@tiansu/web-cli` — 一个本地 CLI 工具，内置天溯组件库的离线元数据（组件列表、API 文档、Demo 示例、设计变量）。用它查询组件知识，基于真实数据生成代码。所有数据离线可用，无需网络。

### 第零步：加载代码生成规范

在编写任何组件代码之前，先执行：

```
Read references/code-generation.md
```

该文件包含代码生成红线，必须遵守。

## 安装

每次执行任务前，首先确保 CLI 已安装：

```bash
which tsweb || npm install -g @tiansu/web-cli
```

如果安装失败（权限不足、网络超时、Node 版本不兼容），按以下顺序尝试：

1. 使用 sudo（macOS/Linux）或以管理员身份运行终端（Windows）重试
2. 如果全局安装受限，改用 `npx @tiansu/web-cli` 临时执行
3. 上述均失败时，告知用户具体错误信息，引导手动安装：

```bash
npm install -g @tiansu/web-cli
# 或
pnpm add -g @tiansu/web-cli
```

CLI 要求 Node.js >= 18。可通过 `node -v` 检查当前版本。

### 项目初始化

在新项目中接入本 Skill：

```bash
tsweb setup --client <client> --mode skill
tsweb setup --client <client> --mode skill --project ./my-project
```

前置要求：`@tiansu/web-cli` 已全局安装。

部署后重启 AI 会话，若 Agent 自动执行 `tsweb info` / `tsweb list` 等命令并输出 JSON 结果，即为加载成功。

`tsweb setup` 仅复制 Skill 描述文件，不安装任何依赖或修改项目代码。

## 输出规范

1. **必须使用 `--format json`** — 每个命令都支持 `--format json`，输出结构化 JSON 数据供精确解析，避免正则匹配文本输出导致的误差。不要使用 `--format text`。
2. **数据查询结果直接以 JSON 格式呈现** — 当用户请求查看组件列表、组件信息、设计变量等数据时，直接将 CLI 返回的 JSON 数据格式化后呈现给用户，不要转换为表格或纯文本摘要。例外：场景 1（编写代码）、场景 2-分组呈现（按分类分组呈现）。
3. **编写代码与分组呈现例外** — 场景 1 以代码块呈现最终代码；场景 2 默认按 `category` 分组以层级结构呈现组件。
4. **错误信息直接呈现** — 当命令执行失败时，直接将 CLI 返回的错误 JSON 呈现给用户，不要隐藏或自行解释。

## 错误与容错

### 命令执行失败时的行为

1. 命令返回错误 JSON 时（如组件不存在、参数非法），直接将错误信息呈现给用户。CLI 已内置模糊匹配建议（如 `"你是否要找：button, buttons"`），无需额外处理。
2. 命令执行超时或网络问题时，重试一次；仍失败则告知用户。
3. CLI 命令本身崩溃（非 JSON 输出）时，告知用户错误信息，建议运行 `tsweb <command> --help` 查看用法。

### 组件名处理规则

1. 组件名大小写不敏感 — CLI 内部已做 `.toLowerCase()` 处理，`Button`、`button`、`BUTTON` 均可。
2. 用户输入拼写近似错误时，CLI 会自动返回模糊匹配建议，直接向用户展示建议即可。
3. 用户输入中文/描述性需求时（如"告警按钮""提示信息"），优先使用 `tsweb search <关键词> --format json` 搜索，必要时加 `--deep` 扩大范围。不要直接猜组件名执行 `tsweb info`。
4. 不要自行猜测组件名是否存在 — 始终通过 `tsweb list` 或 `tsweb info` 验证。

### API 查询为空时的行为

1. `tsweb info` 或 `tsweb doc` 返回的 `props`/`slots`/`events`/`methods` 为空数组时，如实告知用户该组件暂无对应 API。
2. `tsweb demo` 返回空数组时，告知用户该组件暂无 Demo 示例。
3. **绝不凭空编造** — API 为空不代表可以自由发挥，必须如实呈现查询结果。

## 场景

### 1. 编写天溯组件代码

当用户要求写天溯组件代码时，严格遵循以下流程：

```bash
# 第零步：检查项目中 ts-web-package 的版本，决定引入方式
node -e "const { readFileSync } = require('fs'); const { resolve } = require('path'); const pkg = resolve(process.cwd(), 'node_modules/@tiansu/ts-web-package/package.json'); const { version } = JSON.parse(readFileSync(pkg, 'utf-8')); console.log(version);"

# 第一步：查询组件 API（Props、Slots、Events、Methods）
tsweb info <Component> --format json

# 第二步：获取官方 Demo 示例作为代码起点
tsweb demo <Component> basic --format json

# 第三步：如需要完整文档，获取全量 API 信息
tsweb doc <Component> --format json

# 第四步：如涉及样式，查询设计变量
tsweb design --format json
```

**工作流：** 检查版本 → `tsweb info` → 解析 Props/Slots/Events/Methods → `tsweb demo` → 获取示例模板 → 基于真实 API 生成代码。

**代码生成规范：**

- 技术栈为 **Vue 3 + TypeScript**，使用 `<script setup lang="ts">` 组合式 API
- **引入方式**（根据第零步检查到的版本决定）：
  - `>= 2.0.0`：`import { TeButton } from '@tiansu/ts-web-package'`
  - `< 2.0.0`：`import { TeButton } from '@tiansu/element-plus'`
- 组件使用时以 `Te` 为前缀，如 `<te-button>`
- 生成代码时，Props 的值必须在 `tsweb info` 返回的合法值范围内。只使用查询到的真实 API，不凭空编造
- 代码需包含完整的 `<template>`、`<script setup lang="ts">`、`<style>` 区块

### 2. 浏览可用组件 / 获取组件列表

当用户询问有哪些组件、想浏览组件列表时：

```bash
tsweb list --format json
```

根据用户意图选择呈现方式：

- **分组呈现**（默认）：大多数情况下，按 `category` 分组以层级结构呈现，便于快速了解组件库全貌：

```
基础: Button 按钮、Icon 图标
表单: Input 输入框、Select 选择器、Checkbox 多选框
数据展示: Table 表格、Pagination 分页、Tag 标签
反馈: Dialog 对话框、Message 消息提示、Loading 加载
```

- **原始 JSON**（仅当用户明确要求）：用户说了"JSON 格式"、"原始数据"、"JSON 输出"等明确关键词时，才直接输出 JSON 数组。

### 3. 查询组件 API

当用户询问某个组件的属性、插槽、事件时：

```bash
tsweb info <Component> --format json
```

直接呈现返回的 JSON，包含 `name`、`nameZh`、`description` 以及 `props`、`slots`、`events`、`methods` 数组。

### 4. 获取 Demo 示例

当用户需要组件的代码示例时：

```bash
# 获取指定 demo，返回 { name, code }，直接呈现 code 为代码块
tsweb demo <Component> <demo名称> --format json

# 获取该组件的全部 demo，返回 { demos: [{ name, code }, ...] }
tsweb demo <Component> --format json
```

指定 demo 名称时，返回 `name` 和 `code`，直接呈现 `code` 为代码块。
不指定名称时，返回 `demos` 数组，每个元素包含 `name` 和 `code`。

### 5. 查询设计变量

当用户询问颜色、字体、间距等设计规范时：

```bash
tsweb design --format json
```

直接呈现返回的 JSON，包含 `colors`、`typography`、`spacing`、`borderRadius`。

### 6. 查看完整文档

当用户需要组件的全部文档信息时：

```bash
tsweb doc <Component> --format json
```

直接呈现返回的 JSON，包含 `name`、`nameZh`、`description`、`whenToUse` 以及全部 API 数组。

### 7. 需求模糊场景引导

当用户需求不明确时（如"写个弹窗"、"做一个选择器"但未指定具体组件名），先使用 `tsweb list` 列出所有可用组件，让用户确认目标组件后再继续查询。不要猜测组件名直接执行命令。

> **提示**：如果用户需求包含多个关键词（如"告警按钮""成功提示"），先按场景 8 拆解「组件类型」与「修饰语」，再决定用 `tsweb search` 还是 `tsweb list`。

### 8. 组件名消歧与搜索

当用户需求包含修饰词 + 组件类型时（如"告警按钮""成功提示""主要按钮"），需要正确拆解并匹配组件。

**消歧工作流：**

```bash
# 第一步：用完整需求搜索，获取候选组件列表
tsweb search "告警按钮" --format json

# 如果搜索结果不够精确，只用类型词再搜
tsweb search "按钮" --format json

# 搜索无结果时，用 list 浏览全部组件
tsweb list --format json
```

返回结果按 `score` 降序排列，`matchedBy` 字段说明每个命中的来源。选择 `nameZh` 与「组件类型词」匹配的结果。

**消歧原则：**

1. **先拆解用户意图**：识别 `[修饰/上下文] + [组件类型]`
   - "告警按钮" → 修饰: "告警"，类型: "按钮" → **Button**
   - "成功提示" → 修饰: "成功"，类型: "提示" → **Alert**
   - "主要按钮" → 修饰: "主要"，类型: "按钮" → **Button**

2. **修饰词是 Props，不是组件名**：
   - "告警" → Button `type="warning"`
   - "成功" → `type="success"`
   - "危险/错误" → `type="danger"`
   - "加载中" → `loading`
   - "禁用" → `disabled`
   - "朴素" → `plain`
   - 拿到正确组件后，用 `tsweb info <组件名>` 确认对应 prop 是否存在

3. **口语 → 组件映射速查**（常见易错场景）：
   - 弹窗/弹层 → Dialog 对话框
   - 下拉/下拉框 → Select 选择器
   - 气泡/提示气泡 → Popover / Tooltip
   - 轮播/滑动 → Carousel 走马灯
   - 骨架/占位 → Skeleton 骨架屏
   - 穿梭/转移 → Transfer 穿梭框
   - 数字框/计数器 → InputNumber 数字输入框

4. **搜索无结果时（`DATA_NOT_FOUND`）**：不要猜测或编造组件名。先用类型词重新搜索，再 `tsweb list` 核对全部组件，或让用户确认。

**`tsweb search` 命令说明：**

```bash
tsweb search <关键词> --format json    # 默认搜索 name + nameZh + category
tsweb search <关键词> --deep           # 额外搜索 description 文档描述
```

`--deep` 适用于仅凭组件名无法匹配的场景（如搜索"提示信息"定位到 Alert），但多数情况下默认搜索已足够。

| Flag                | 用途                                            |
| ------------------- | ----------------------------------------------- |
| `--format <format>` | 输出格式，默认 `json` |
| `--lang <lang>`     | 输出语言：`zh`、`en`（默认 `zh`）               |
| `-V, --cli-version` | 输出版本号                                      |

## 工作流调用要求（Workflow Integration）

本 Skill 由工作流各阶段在**涉及组件**时通过 Skill 工具调用（`tiansupowers:ts-components` / `/ts-components`）：

- **ts-design**：选择每个组件前调用，核实组件真实 API 后写入设计文档
- **ts-implement**：编码使用每个组件前调用，按真实 API 生成代码
- **ts-design-review**：评审设计中的组件选择与 Props 是否真实存在
- **ts-code-review**：审查代码中组件名 / Props 是否为组件库真实 API

**禁止绕过本 Skill**：未加载本 Skill（未读取其规范与 `references/code-generation.md`）时，不得直接运行裸 `tsweb` 命令查询或生成组件代码。

## 关键规则

1. **先查询，再行动** — 任何时候涉及天溯组件，第一步永远是运行 `tsweb info` 查询真实 API，绝不要凭记忆或猜测。
2. **始终使用 `--format json`** — 所有命令必须带 `--format json`，解析结构化 JSON 数据，不做正则匹配。
3. **数据查询直接输出 JSON** — 用户请求查看数据（组件列表、API、设计变量等）时，直接将 CLI 返回的 JSON 格式化呈现，不要转换为表格或摘要。例外：场景 1（编写代码）、场景 2 默认分组呈现。
4. **Demo 优先** — 编写代码前使用 `tsweb demo` 获取官方示例，确保代码风格和用法与组件库一致。
5. **Props 值必须合法** — 设置 Props 时只使用 `tsweb info` 返回的类型定义中的合法值，不自行编造。
6. **设计变量保持一致性** — 涉及颜色、间距、字体等样式时，可用 `tsweb design` **查询**组件库的设计变量以了解主题口径；但**不得据其在页面/原型里重建一套视觉值**——页面与原型一律用运行时语义变量名（`--te-*`），唯一值源是组件库主题（`references/rules/ui-prototype-standard.md` §7.1）。
7. **API 为空不编造** — 查询结果为空时如实告知用户，绝不凭空编造 API 或 Demo 代码。
8. **需求模糊先搜索** — 用户未指定具体组件名时，用 `tsweb search <关键词>` 搜索；搜索无结果再用 `tsweb list` 列出全部，由用户确认后再继续。
9. **先拆类型，再选组件** — 用户描述中的修饰语（告警、加载、禁用）是 Props/变体，不是组件名。先通过「组件类型词」匹配到正确组件，再用 `tsweb info` 确认 Props 取值。
10. **组件来源唯一权威** — 组件来源判定（`@tiansu/ts-web-package` vs `@tiansu/element-plus`，按版本号 ≥2.0.0 / <2.0.0）以本 SKILL 的场景 1 规则为准，`references/rules/vue-standard.md` 遵循本规则。
