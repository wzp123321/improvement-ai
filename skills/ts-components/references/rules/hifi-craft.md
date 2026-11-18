# 高保真工艺规则（HiFi Craft）

> 本文件把「如何把界面做得像人设计、而非 AI 默认产物」的**品牌无关工艺**浓缩成可引用规则。
> 它是**增强层**，叠在 `references/design-systems/tiansu-web/DESIGN.md`（品牌观感）与 `references/rules/ui-prototype-standard.md`（视觉契约/原型规范）之上，
> 不取代二者；与二者冲突时以 DESIGN.md / `references/rules/ui-prototype-standard.md` 为准。
>
> 来源与归属：
> - 反 AI 味规则改自 [refero_skill](https://github.com/referodesign/refero_skill)（MIT），与 `references/assets/open-design/craft/anti-ai-slop.md` 一致；
> - 生成工作流参照 Anthropic 官方 `frontend-design`（Apache-2.0），入口见 `ts-frontend-design` 技能。
>
> `references/assets/open-design/craft/` 目录另存 11 本分主题规则书（`references/assets/open-design/craft/*.md`）。需要某一维度细节时读对应文件，
> 本文件只保留**每屏生成必查**的收敛清单。

---

## 1. 前置纪律（不绕过门禁）

- 若属「必须走流程」的开发需求（触发词命中 references/hard-gate.md 三级判定）→ 先完成**阶段一**（前端概设 + 后端概设 + UI 原型，经用户确认）→ 再走 `ts-design`；`ts-design` 默认只**消费**阶段一原型（§2.4 读原型落组件级布局、不重新选组件），本规则此时作为其**校验工艺**。需要独立出一版视觉稿时走 `ts-frontend-design`。
- 仅当用户明确要「独立高保真视觉稿 / 美化现有界面 / 改版视觉预览 / 营销落地页」且**不进入实现代码**时，才作为独立入口执行（`ts-frontend-design`）。
- 产物一律是**真 `te-*` 组件组合的 Vue 3 + TS 单文件组件**（设计产物，落 **`<项目根>/prototype/`**；交接件 `archive-spec/product/ui-*/_notes.md`），不写任何 `src/` 生产代码；实现时原型**就地晋升**进 `src/views/<module>/`（`references/rules/ui-prototype-standard.md` §3.2）。

## 2. 决定一个具体的视觉方向（先于动手）

- 从受众/主任务/领域/语气出发，定**一种**方向：数据密集企业、克制编辑、沉稳业务、紧凑运营……并落到字体、间距、色彩、层级、动效、组件形态上。
- **避免**通用 AI 默认：蓝紫渐变、玻璃拟态卡片、千篇一律的 SaaS 布局、超圆角卡片、无意义的装饰 blob。
- 目标是「80% 稳妥模式 + 20% 让人记住的选择」：一个大胆排版决定 / 一个单一色彩决定 / 一个产品级微文案 / 一个用过产品的人才写得出的细节。

## 3. 配色与 accent

- 主色**取组件库主题的 `--te-color-primary`**（真组件形态下主题即唯一值源，不再走 `tsweb design` 取值，契约 §7.1）；**禁止** Tailwind indigo 一类的蓝紫默认色（`#6366f1/#4f46e5/#4338ca/#3730a3/#8b5cf6/#7c3aed/#a855f7`）当强调色——这是教科书级 AI 味。
- **accent 每屏可见 ≤ 2 处**（典型：一个状态标签/链接 + 一个主按钮）；主按钮每屏 ≤ 1。
- 语义色独立：success/warning/danger 只表状态，不挪用主色；危险操作独立 danger + 二次确认。
- 不用双色“信任”渐变 hero；扁平表面 + 有意的排版层级更稳。
- 页面**不写裸 hex 色值**；需要主题变量时直接用运行时语义变量名（`--te-color-*` / `--te-text-color-*` …），**不填 `:root`、不用 `--p-*`**（旧形态做法，已作废——契约 §7.1）；组件外观一律不覆盖（契约 §7.2）。

## 4. 排版

- 字号**由组件库主题决定**，页面不再自选档位（页面自写文本的数值见契约 §4.2）；不写档外字号（如 13px）。字重三档（400 / 500–550 / 600），很少 700+。
- CJK 覆盖不可省：大标题（≥32px）行高 1.3–1.4、正文 1.7–1.8、行宽 ≤65ch；中文标题不加负字距（详见 `references/rules/ui-prototype-standard.md` §4）。
- 全大写必加 0.06–0.1em 字距；小字 0.01–0.02em；UI 标签/按钮 0.02em。
- 标题**禁止**裸 `system-ui` 当视觉主体；字族 ≤ 2 + 系统 fallback。

## 5. 状态与反 AI 味（P0 必查）

凡拉数据/接收数据的区域，**五种状态齐全**：loading / empty / error / populated / edge；
error ≠ empty；error 文案顺序 = 发生了什么 + 原因(可知时) + 能做什么；动画永不作唯一状态信号。
（实现细节见 `references/rules/ui-prototype-standard.md` §5。）

**P0（必须修）**——直接对齐 `references/assets/open-design/craft/anti-ai-slop.md`：
1. ❌ Tailwind indigo 系作强调色（上表六值）；
2. ❌ 双色“信任”渐变 hero（蓝紫/蓝青/靛粉）；
3. ❌ emoji 当功能图标（`✨🚀🎯⚡🔥💡` 出现在标题/按钮/列表/icon 类里）；用组件库图标（`te-*` 的 `icon` prop），无对应图标时用等线（1.6–1.8px 描边）SVG + `currentColor`，**不手写图标路径**；
4. ❌ 展示文本硬编码 Inter/Roboto/system-ui 而非绑定字族（Te 场景：用 `--te-font-family`，见契约 §4.3）；
5. ❌ 圆角卡片 + 左侧彩色边框的“AI dashboard 瓷砖”；
6. ❌ 编造指标（“效率提升 10×”）——真实来源或标注占位；
7. ❌ 占位文案 lorem / “功能一、功能二” ——空板块用构图解决。

**P1（应修）**：段落图片外链 CDN（unsplash/placehold…）；`var(--accent)` 一屏可见 ≥6 次；
千篇一律的 Hero→Features→Pricing→FAQ→CTA 模板骨架无变化。

**P2（锦上添花）**：无意义的装饰 blob/波浪背景；全屏完美对称无视觉张力。

## 6. 无障碍与动效基线（Te 场景）

- 对比度：正文字 ≥4.5:1，大字 ≥3:1，控件与相邻表面 ≥3:1；
- `:focus-visible` 可见；`<label for>` 真绑定，占位符 ≠ 标签；`aria-invalid` + `role="alert"` 报字段错；
- **页面自建区域**的动效曲线 `cubic-bezier(0.2,0,0,1)`；即时 50–100 / 状态确认 150 / 进入 200–300 / 跨屏 300–500ms（非跨屏 <500ms）——**组件内部动效由组件库决定，页面不覆盖其曲线与时长**（契约 §5.5）；
- 默认处理 `prefers-reduced-motion`；透明度/颜色淡入淡出可保留，轴向运动关闭。

## 7. 交稿自检清单

- [ ] 视觉方向单一、可描述；无 AI 默认蓝紫/渐变/瓷砖/玻璃卡片
- [ ] 每屏五种状态可演示，无 error-as-empty；交互控件 hover/focus/active/disabled/loading 齐全
- [ ] 配色/字体/间距/圆角均来自**组件库主题**，未覆盖组件外观、未写裸 hex；accent ≤2/屏
- [ ] CJK 行高、字距、行宽符合 `references/rules/ui-prototype-standard.md` §4
- [ ] 无 emoji 功能图标、无 lorem、无编造指标
- [ ] 页面原型场景：每个区域由真 `te-*` 组件承载（区域→组件映射已在模板里），交接件写进 `archive-spec/product/ui-*/_notes.md`（契约 §9/§10）；`prefers-reduced-motion` 生效
- [ ] 产物落位正确：原型 `.vue` 在 `<项目根>/prototype/`、`_notes.md` 在 `archive-spec/product/ui-*/`；未写任何 `src/` 文件（契约 §3.2）
