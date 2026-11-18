
# Tiansu Web (Te) — Design Language

> 本文是**观感纪律散文**（“观感语法”），不是 token 值表。所有色值 / 字号 / 间距等
> 具体值见同目录 `tokens.css`（真实主题快照）；Te 组件真实运行观感见
> `components.html` 与 `preview/`。生成任何界面都以本节 + `tokens.css` 为准，
> **禁止凭记忆写 token 名或散落 hex**。
>
> 身份约定：组件命名空间 `te`、组件前缀 `Te`、发布包 `@tiansu/ts-web-package`。
> 本文面向使用本包的 agent，正文语言：中文。

---

## 1. 视觉主题与氛围

天溯 Te 是**结构化企业中后台 / B2B 数据与运营工作台**：页面像一张张严谨的信息台，
不像营销官网。氛围关键词：**秩序、克制、数据感、低装饰**。

- 页面底是灰感表面（`--te-bg-color-page`），内容承载在白色卡片/表体
  （`--te-bg-color-blank`）上；块与块用极轻描边（`--te-border-color-*`）与留白
  分隔，不靠大面积色块。
- 视觉锚点是**单一品牌蓝** `--te-color-primary`，只给主操作、选中态、链接等
  “值得被点”的地方；每屏 accent（额外强调色）可见 ≤ 2 处，其余全走中性。
- 信息密度偏高，但层级靠文字字阶/字重/位置拉开，不靠颜色堆叠。
- 成功/警告/危险只在表达状态时出现，不参与装饰。

一句话：把页面做成**业务方愿意填数据的正经系统**，而不是一个“好看的演示页”。

## 2. 色彩角色与用途

色彩分工在 `tokens.css` 的语义块里，使用时**按角色取名，不按十六进制取名**：

- **主色 primary**：实底主按钮、选中项、链接、关键数据。它是一条十级色板
  （`--te-brand-color-1..10`，第 7 级为基准）；状态名是固定的：
  - hover = 6、active = 8、disabled = 5；
  - 浅底（hover 底色/标签底）= 1、light-hover = 2、light-border = 3。
  - 运行时语义名 `--te-color-primary-{hover,active,disabled,light,light-hover,light-border}`
    已指向这些档位，直接用语义名。
- **success / warning / danger / info 只表状态**：tag、badge、表单校验、危险操作、
  进度/状态点。danger 操作必须配二次确认，不拿主色顶替“危险”。
- **`--te-color-danger` 与 `--te-color-error` 同色**（都 `#e60a15`）：danger 用于
  操作/按钮语义、error 用于校验消息，同一界面选一个语义名贯穿，别两套并排。
- **中性分两个灰族，别混**：
  - `gray` → 边框、分隔线、info 基底；
  - `gray_brand`（带一点品牌蓝味的灰）→ 页面/表面/骨架底。
  - info 的 hover/active/disabled/light 别名取自 `gray`（见 tokens.css），但 info
    基准 `--te-color-info` = EP 灰 `#909399`，**并不落在 gray 十级里**（gray-7 才是
    `#969696`）——读两个族时别把 info 基座当成 gray 档位之一。
- **文字是黑底 alpha 灰阶**：primary `.85`（正文/标题）、secondary `.55`
  （次要说明，≥12px）、placeholder `.4`、disabled `.25`。在白卡上的等效约
  `#262626 / #737373 / #999999 / #BFBFBF`。disabled 色只用于禁用态，不作正文色。
- **bg / fill 档位**：page/secondary/tertiary/component(+hover/active/disabled)/
  blank/overlay 分工表面层级；`fill` 供大面积无边框填充区。
- **data1–10**（每组 default/light/light-border）给图表、多序列、数据标签用；
  数据驱动场景才出现，不用于普通按钮。

> ⚠ **坑（勿照 Element Plus 直觉用）**：本主题保留的 `--te-color-*-light-3/5/7/8/9`
> 与 `-dark-2` 是**别名反转**——`light-3` 实为 hover（第 6 档，较深）、`light-9` 才是浅底、
> `dark-2` 是 active（第 8 档）。本包 tokens.css 有意不列它们；写代码一律用
> hover/active/disabled/light/light-hover/light-border 语义名。
> 另外本主题只声明 `color-scheme: light`，没有 dark 扩展色板：不要为深色稿重新映射
> 这套扩展层级，深色观感以真实产品运行态为准。

## 3. 字体排版

- **默认族** `--te-font-family`：西文 Helvetica 系 + 中文 PingFang/微软雅黑回退，
  足够中后台正文。特殊字是**附属 @font-face 声明，不自动生效**：
  - `D-DIN` / `D-DIN Bold`（`--te-font-family-d-din` / `-d-din-bold`）——数字、数据、
    大标题想让数字“更工程”时显式指定；
  - `YouSheBiaoTiHei`——中文标题展示字，仅大屏运营位慎用。注意它**没有对应
    `--te-*` 变量**（D-DIN 才有），要用直接写字面族名
    `font-family: "YouSheBiaoTiHei", var(--te-font-family)`，勿自造变量名。
- **字阶用 `b/h/oh` 语义**（tokens.css）：b=正文、h=标题、oh=超大标题；
  正文默认 **14px（b14）**，行高基线 24px / 正文 1.7–1.8；字重 primary 500。
  大标题（≥32px）行高 1.3–1.4。
- **CJK 排版**：正文行宽 ≤ 65ch；全大写西文加 0.06–0.1em 字距；中文标题不加负字距。

## 4. 组件样式与语气

用 Te 组件语言说话，通用观感按 `tokens.css` + `components.html`：

- **尺寸**：控件默认高 32（`--te-component-size`），large 40 / small 24；表单行内
  对齐默认档。**高度别手写 22/28px 之类的零碎值**。
- **圆角**：卡片/按钮 4（`--te-border-radius-base`）、小控件/标签 2
  （`--te-border-radius-small`）；胶囊按钮/标签 pill 用 `--te-border-radius-round`
  （20px）；开关滑块、圆形头像等**整圆**用 `--te-border-radius-circle`（100%）——
  round ≠ circle，别用 999px 手写凑圆。
- **Button**：主按钮 = primary 实底白字；次按钮 = 白底 1px 描边；
  幽灵/文字按钮无底。hover/active 走向语义状态色；loading 用图标 + 文案，
  禁用不响应 hover。
- **Input / Select 等表单控件**：默认描边 `--te-border-color-component`，
  hover 加深一档，focus 换 primary 描边；宽度随内容/栅格，高度 32 档。
- **Table**：表头用浅灰面（`--te-bg-color-secondary`）+ 次要文字
  （`--te-text-color-secondary`），行 hover 用极浅悬浮面（`--te-fill-color-lighter`，
  语义同 EP 表行 hover 取 fill-lighter）；当前行/选中行用 primary-light 级别的浅底
  （不整行铺主色）；空/载/错态齐全。
- **Tabs / 分页 / 表单弹窗**：激活态用主色 2px 细条或主色文字 + 浅底；
  弹窗承载新增/编辑/删除确认，不整页跳转。
- **业务模块组件**（sidenav、tablebar 查询条、module-table、tags-view 等）是 Te
  自己的观感：高保真稿照它的布局与信息结构画，**不要另造等价观感**。
- 每个区域直接落到真 `te-*` 组件上（原型即 Vue SFC，落项目根 `prototype/`），区域→组件映射写进
  交接件 `archive-spec/product/ui-*/_notes.md`（规则见 `references/rules/ui-prototype-standard.md` §9/§10 与 ts-design 流程），让后续实现不靠猜。

语气总结：**状态色只表状态、主色只给“可点”、层级靠排版不靠颜色、空态讲人话并给主操作。**

## 5. 布局原则

中后台页面有固定节奏，**禁止每页发明布局**：

```
页面标题 → 查询区(te-tablebar) → 工具条 → 表格(TeModuleTable) → 分页
新增 / 编辑 / 删除 → 弹窗(te-dialog > te-form)；详情 → te-descriptions
```

- 一个功能用一块能说清的信息结构表达；能单块表达就不叠块。
- **间距一律取 `--te-space-*` 档位**（4/8/12/16/20/24/32/40/48/64/80/96/160），
  不写随机 px：卡片内边距 16–24、区内 8–16、区块间 24–32、页面边距 24–32。
- 栅格/列以 8px 基线对齐；表单 label 对齐一致（右对齐或统一宽度），错误与帮助
  文案贴着控件。
- 密度策略用尺寸档表达：默认 32、紧凑场景允许 small 24；别靠压缩行高换取密度。

## 6. 层级与阴影

企业界面**不靠深度讲故事**：层级由表面明度与描边表达，阴影只给“浮起来的层”。

- 静态卡片默认极轻或免投影；卡片 hover/浮层感用 `--te-box-shadow-lighter/light`；
  `--te-box-shadow-dark` 留给弹窗/抽屉/下拉等 popper 层。
- 遮罩用 `--te-overlay-color-lighter`（半透明黑）压住下层，内容仍在白卡上；
  层级 z 用 `--te-index-{normal,top,popper}`，不要自造 99999。
- 过渡统一走 tokens 的 `--te-transition-{all,fade,md-fade,fade-linear,border,
  box-shadow,color}` 复合档（= 属性 + 时长 + 曲线），时长只取
  `--te-transition-duration` / `-fast`，别散写随机秒数与自制曲线。
- 避免过深、多层的装饰阴影（那是营销卡片的语言）。

## 7. Do / Don't

**Do**
- 值一律走 `tokens.css` 语义 token 与 Te 组件 props；颜色用语义角色，不用散落 hex；
  间距取档位；需要“浅底 + 描边”时用对应 light/light-border 语义。
- 主色只给主操作/选中/链接，accent ≤ 2 处/屏；危险操作独立 danger + 二次确认。
- 用真实、贴近业务的文案与数据；空态讲人话并给主操作；五态
  （loading/empty/error/populated/edge）齐全，error ≠ empty。
- hover / focus-visible / active / disabled / loading 显式存在；loading 配静态骨架或文案。
- 大标题、表格数字、状态标签区分出文字层级。

**Don't**
- ❌ 自造主色 / 第二强调色；主色落在蓝紫 AI 默认上（如 `#6E56CF/#7C3AED`）。
- ❌ 双色渐变 hero、圆角卡片 + 左侧彩条“瓷砖”、蓝紫渐变按钮。
- ❌ emoji 当功能图标；lorem / “功能一”占位；编造指标。
- ❌ 扁平层级（全站同字号同字重）；空列撑宽表格；随机 px。
- ❌ 装饰性动效、无限转圈、动画作为唯一状态信号；error-as-empty。
- ❌ 把视觉稿当生产代码：原型只进**项目根 `prototype/`**，交接件 `_notes.md` 归档
  `archive-spec/`（落位见 `references/rules/ui-prototype-standard.md` §3.2）；实现时原型就地晋升进
  `src/views/<module>/`，回到 Te 组件 + `var(--te-*)`，禁止像素级复刻裸样式。

## 8. 响应式与断点

断点与 Te 主题一致：**sm 768 / md 992 / lg 1200 / xl 1920**，小于 768 为 xs。

- 中后台以桌面为基准（默认 md–lg 为主战场），窄屏**优先降级不重排**。
- 表格在窄容器内放**横向滚动容器**，不硬挤列宽、不砍列表达核心信息；工具条允许
  换行堆叠；查询区可折叠。
- 最小触达目标 ~32px，可点击控件间距 ≥ 8；缩放字号只在必要时按档降（如 14→12 走
  b 档，不写 13px）。
- 栅格用内容宽度百分比/列，别让整页宽度跑满 4K 而失去可读行宽。

## 9. Agent 提示词指南

**开写前**：值源是**组件库主题**，页面**不复制 `tokens.css` 快照、不填 `:root`、不自造 `--p-*` 前缀**
（值源条款以 `references/rules/ui-prototype-standard.md` §7.1 为准）。需要某角色颜色时引用**运行时语义变量名**，
例如：主按钮底 `var(--te-color-primary)`、hover `var(--te-color-primary-hover)`、
浅底标签 `var(--te-color-primary-light)` + 描边 `var(--te-color-primary-light-border)`、
表头底 `var(--te-bg-color-secondary)`、行悬浮 `var(--te-fill-color-lighter)`、
状态 tag `var(--te-color-success-light)` + `-light-border`（danger/warning/info 同构）、
表头分隔 `var(--te-border-color-divider)`、正文/次要文字
`var(--te-text-color-primary) / var(--te-text-color-secondary)`、卡片圆角
`var(--te-border-radius-base)`、内边距 `var(--te-space-16)`。

示例指令片段：

```text
用 tiansu-web 画一个“设备列表”页：页面标题 + te-tablebar 查询区（名称/状态/时间）+ 
工具条右侧一个主按钮“新增设备”(var(--te-color-primary))，表格行选中给浅底
(var(--te-color-primary-light))、分隔线走 var(--te-border-color-divider)，
状态列用 success/warning/danger/info 语义 tag，
空白区由真 `te-*` 组件承载（`te-empty` / `te-skeleton`）。
```

**迭代纪律**：每次改动回到 token 语义；不新造变量、不写裸 hex、不把状态色当装饰。
**收尾自检**：对照 `references/assets/open-design/craft/` 与 `references/rules/hifi-craft.md` 的反 AI 味 P0（单一主色、真实文案、
无占位指标、层级明确、hover/active/disabled/loading 覆盖），通过后再交付。
**进实现**：本视觉稿只表达意图，实现一律回 Te 组件 + tokens（ts-implement），
禁止像素级裸 CSS 复刻。
