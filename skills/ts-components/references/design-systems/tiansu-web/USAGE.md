# Tiansu Web (Te) — Usage Guide

> 本包体例对齐 OpenDesign `references/design-systems/<slug>/`。DESIGN.md 是**观感语法散文**，
> tokens.css 是表示层快照（值取自 Te 主题 `ts-web-package` theme-chalk 真实快照，
> 本包不驱动运行时）。

## Read Order

按以下顺序阅读，顺序即注入优先级（ts-design / ts-implement / ts-design-review 在 Step 0 全部读入）：

1. `tokens.css` —— 先看**值**：语义角色与状态别名、gray/gray_brand 双中性族、
   text/bg/fill/border、字阶与间距档、圆角/尺寸档/动效时长的当前快照。
   值取自 Te 主题真实快照（来源与刷新方法见文件头注释）；若与运行态 `var(--te-*)`
   不一致，以真实 Te 运行时主题为准。
2. `DESIGN.md` —— 再看**纪律**（9 节观感语法）：单主色 + accent ≤ 2/屏、布局节奏、状态语义色、
   动效曲线与时长、业务文案、反 AI 味。DESIGN.md 是散文，不复制 token 值。
3. `references/rules/ui-prototype-standard.md` —— 需要生成页面原型（真 `te-*` 组件组合的 Vue 3 + TS SFC）时必读：
   产出形态与接入前提 §1、三步结构分析 §2、五态与数据接入 §5、样式边界 §7、区域→组件映射 §9、
   命名与落位 §3.2、CJK 行高与字距 §4。
4. 涉及具体 Te 组件 Props/Events/Slots —— **禁止凭记忆**，走 `ts-components` 流程用
   `tsweb info <组件> --format json` 核实。
5. 想看“渲染后的样子”：本包带 `components.html`（参考组件 fixture）与
   `preview/`（colors/typography/spacing 三张预览页）。fixture 几何为近似，
   需要像素级真实观感仍以真实 Te 页面 / 组件运行态为准。

## Design Highlights

- **结构化企业中后台**：页面标题 → 查询条 → 工具条 → 表格 → 分页；新增/编辑/删除进弹窗。固定节奏，禁止每页发明布局。
- **单一主色 + accent ≤ 2 处可见/屏**：典型 = 一个状态标签/链接 + 一个主按钮；其余中性。主色取组件库主题的 `--te-color-primary`，禁止蓝紫默认 AI 色。
- **语义色独立**：success/warning/danger 只表状态（tag/badge/校验/危险操作），不挪用主色；危险操作独立 danger + 二次确认。
- **表格优先**：查询区 `te-tablebar`、表格 `TeModuleTable`、弹窗 `te-dialog > te-form`、详情 `te-descriptions`；能单块表达不叠块。
- **CJK 排版**：大标题（≥32px）行高 1.3–1.4、正文 1.7–1.8、行宽 ≤65ch；全大写必加 0.06–0.1em 字距（中文标题不加负字距）。
- **状态覆盖**：凡拉数据/接收数据的区域，loading / empty / error / populated / edge 五态齐全；error 不等于 empty。
- **动效**：曲线 `cubic-bezier(0.2,0,0,1)`，即时 50–100 / 状态确认 150 / 进入 200–300 / 跨屏 300–500ms（非跨屏 <500ms）；`prefers-reduced-motion` 关轴向运动；动画永不作唯一状态信号。
- **文案**：按钮 = 动词 + 对象，全站同动作同词；微文案业务化；UI 中文业务词，emoji 不作功能图标。

## Do

- 值一律走 token / 组件 props：色用语义角色，不用散落 hex；间距取档位，不写随机 px。
- 用真实、贴近业务的文案与数据；空态讲人话并给主操作。
- hover / focus-visible / active / disabled / loading 显式存在；loading 配静态骨架或文案。
- 每个区域由真 `te-*` 组件承载，区域→组件映射写进同目录 `_notes.md`（契约 §10），让 ts-implement 不靠猜。
- 组件 API 用 `tsweb info` 核实后再写。

## Avoid

- ❌ token 之外自造色 / 第二强调色；主色落蓝紫家族；双色渐变 hero；圆角卡片 + 左侧彩条“瓷砖”。
- ❌ emoji 当功能图标；lorem / “功能一”占位；编造指标（“效率提升 10×”）。
- ❌ 扁平层级（全站同字号同字重）；空列撑宽表格；随机 px。
- ❌ 装饰性动效、无限转圈、动画作为唯一状态信号；error-as-empty。
- ❌ 把本包/原型当生产代码：原型只进**项目根 `prototype/`**（交接件 `_notes.md` 进 `archive-spec/`，落位见 `references/rules/ui-prototype-standard.md` §3.2），实现时原型就地晋升进 `src/views/<module>/`；回到 Te 组件 + `var(--te-*)`，禁止像素级复刻裸样式。
