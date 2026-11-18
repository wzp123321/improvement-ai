# 屏型配方：数据看板（Dashboard）

> 挂在 `ts-frontend-design` 下的**屏型配方**，不单独触发；由该技能的 Step 0 按屏型取用。
> 适用「管理后台 / 运营看板 / 分析驾驶舱 / 指标首页」这类**概览屏**。
> 源：OpenDesign `plugins/_official/examples/dashboard`（**改写，非翻译**）。
>
> **2026-09-10 形态变更**：原型由「自包含 HTML」改为「真 `te-*` 组件组合的 Vue 3 SFC」。
> 指标卡改用组件库的 `te-statistic` + `te-card`；**图表区是本屏型唯一需要自建的区域**
> （组件库无图表组件——`tsweb list` 已核实），按 `references/rules/ui-prototype-standard.md` §2 走「视觉方向」判断。

---

## 0. 先判定：这真的是看板吗

| 输入 | 判定 |
| --- | --- |
| 「看板 / 驾驶舱 / 首页指标 / 运营概览」 | ✅ 用本配方 |
| 「XX 列表 / XX 管理 / 增删改查」 | ❌ 改走 `references/recipes/list-page.md` |
| 「实时数据 / 滚动推送 / 监控大屏」 | ❌ 超出范围（本插件无运行时，不做实时与滚动） |

**看板与列表页共用同一套壳**（`te-sidenav` + `te-tags-view` + `te-page-header`），差异只在主区：

- 列表页主区 = 查询区 → 工具条 → 表格 → 分页
- 看板主区 = **指标行 → 图表行**

> ⚠ 常见错误：把看板做成「一堆卡片」。看板的价值是**一屏内可对比的层级**（哪些是指标、哪些是趋势、哪些是明细），不是卡片数量。

---

## 1. 值源与组件核实

- **值源 = 组件库主题**。不填 `:root`、不用 `--p-*`、不抄 tokens 快照（`references/rules/ui-prototype-standard.md` §7）。
- 页面级布局间距取 `--te-space-*` 档位（4/8/12/16/20/24/32/40/48/64/80/96/160），**不写随机 px**。
- **指标卡用 `te-statistic`**（`tsweb info statistic` 已核实：`value` / `title` / `prefix` / `suffix` / `precision` / `group-separator` / `formatter` / `value-style`，具名槽 `prefix` / `suffix` / `title`）。
  数字族与等宽由组件与主题决定，**不在页面写 `font-variant-numeric`**。
- **侧边栏用 `te-sidenav`**，宽度以其为准，不自造 220–260px 这类魔数。
- **图表区无处可依**：`tsweb list` 里没有任何图表组件。该区是**自建区域**，样式边界按 §7.2「页面自建区域的全部样式」处理——可以写全套样式，但仍**不得进组件内部**。

**本屏型必查的 craft 维度**（对应上游 `od.craft.requires`）：

| 维度 | 文件 | 本屏型在哪用 |
| --- | --- | --- |
| `state-coverage` | `references/assets/open-design/craft/state-coverage.md` | 每区独立五态（见 §5） |
| `accessibility-baseline` | `references/assets/open-design/craft/accessibility-baseline.md` | 图表读数、delta 不靠颜色单一表意 |
| `laws-of-ux` | `references/assets/open-design/craft/laws-of-ux.md` | 指标行 ≤4、主图表唯一、时间范围就地可见（信息层级） |

---

## 2. 骨架与区域 → 组件

真组件形态下映射**就在模板里**（`references/rules/ui-prototype-standard.md` §9.1）：

| 区域 | 组件 | 承载 |
| --- | --- | --- |
| 侧边导航 | `te-sidenav` | 品牌位 + 6–8 条导航 + 选中态 |
| 多页签 | `te-tags-view` | 可选，看板首页通常只有一条 |
| 页头 | `te-page-header`（+ `#extra`） | 标题 + 时间范围 + 刷新/导出 |
| 指标行 | `te-card` > `te-statistic` × 3–4 | 标签 + 大数字 + 环比 delta |
| 主图表 | **自建区域** | 全宽 或 2/3 |
| 次区 | **自建区域** / `te-module-table` / `te-timeline` | 选其一 |
| 加载骨架 | `te-skeleton` | 各区 loading 态 |
| 空态 | `te-empty` | 各区 empty 态 |

> ⚠ **壳由 `src/components/` 提供**（`references/rules/vue-standard.md` §3.1）：页面文件置于 `src/views/<module>/index.vue`，
> `te-sidenav` / `te-tags-view` 属应用外壳，**通常不在原型页面文件里**。原型是独立跑的单页时可以带上整个壳，
> 但要在 `_notes.md` 里标明「壳为演示所需，接入时由 `src/components/` 提供」。

**编排规则**：

- 指标行 3–4 个，**不超过 4**。超过 4 个说明没做取舍，拆到别的屏或收进次区。
- 主图表**只有一个**。两个同权重图表 = 没有主次。
- 次区按业务选：趋势延续 → 图表；明细入口 → `te-module-table`；事件流 → `te-timeline`。

---

## 3. 各区域规格

### 3.1 指标卡（`te-card` > `te-statistic`）

- 结构：**标签 → 大数字 → delta**。三层顺序不要倒。标签走 `title`（或 `#title` 槽），数字走 `value`。
- 大数字：字号与行高**由组件与主题决定**，页面不指定（`references/rules/ui-prototype-standard.md` §4.1：组件内部文本不归本阶段管）。
  千分位用 `group-separator`，小数位用 `precision`——**用组件属性表达，不写 CSS**。
- delta：`success` / `danger` 语义色 + 方向箭头 + **对比基准写全**（「较上周」而不是只有百分比）。
- delta **不带文字颜色以外的信号**：颜色不能是唯一状态信号（无障碍 §6）。
- 卡片走 `te-card` 默认语气；**禁止**圆角卡片 + 左侧彩色边框的「AI dashboard 瓷砖」（`references/rules/hifi-craft.md` §5.5）。

### 3.2 图表区（**自建区域**）

组件库没有图表组件，这一屏是**唯一必须自建**的地方，因此也是反 AI 味风险最集中的地方。

- **自绘 SVG，不引图表库**。折线 ≈ 一条 `<polyline>` + 一层淡面积填充；柱状 = N 个 `<rect>`。
- 坐标轴**轻标注**：用主题的次要文字色与降一档字号；**不要**完整网格墙。
- 强调色只用在**一处**数据高亮，不是每根柱子一个色（`hifi-craft.md` §3 accent ≤ 2/屏）。
- 图表必须有 `aria-label` 概述，且**图例不是唯一读数途径**（关键值在旁给出文本）。
- 该区的样式可以全部写在本页 `<style>` 里（§7.2 允许行），但仍**不得用 `:deep()` 进任何组件内部**。
- ⚠ 手绘 SVG 在这里是**合法的**：`code-generation.md` 红线 #1 禁止的是**手写图标路径**（图标要走组件的 `icon` prop）。
  图表不是图标，组件库不提供，只能自绘。

### 3.3 页面头（`te-page-header`）

- 标题 + 时间范围选择（`te-date-picker` / `te-date-switch`）+ 刷新/导出。时间范围是看板的**核心控件**，不要省。
- 导出按钮 `loading` 态用图标 + 文案、**不变宽**（§5.4，由组件提供）。

---

## 4. ⚠ 指标真伪（本配方与原配方的关键分歧）

原 OpenDesign 配方写的是 *"Generate specific, plausible metric names and values"*。在 Te 语境下**必须拆开执行**：

| 对象 | 规则 |
| --- | --- |
| 指标**名** | ✅ **必须业务具体**。「今日订单量」「设备离线率」优于「指标一/指标二」（`references/rules/hifi-craft.md` §5.7 反 lorem） |
| 指标**值** | ❌ **禁止无来源编造**。编造指标是 P0（§5.6） |

具体数值的三种合法处理，按可得性择一：

1. **有真实来源** → 直接使用，并在 `_notes.md` 注明来源字段/接口。
2. **无来源但需体现量级** → 用示例值，UI 上加「示例」角标（不是藏在小字里）。
3. **连量级都不可知** → 用占位并标「待定」，**不要**编一个看起来合理的数字。

> delta 百分比尤其容易踩线：「较上周 +12.4%」在无来源时就是一个编造的精确值。宁可写「较上周 ↑」不写小数。

---

## 5. 五态在看板上的落法

看板的每个**拉数区域**（指标卡、图表、次区表格）各自独立成立五态，不是整屏一个状态：

| 状态 | 看板上的形态 | 用什么产生 |
| --- | --- | --- |
| `loading` | 卡片骨架（保留卡片尺寸，不塌陷）；图表区留同高占位 | `te-skeleton`；或 mock 故意不结算 |
| `empty` | 该区讲人话 + 给主操作（「去创建第一个监控项」），**不留空白卡** | `te-empty`；接口返回空数据集 |
| `error` | 「发生了什么 + 可知原因 + 能做什么」；与 empty **视觉与文案都不同** | `te-result` 或该区自建错误态 |
| `populated` | 默认态 | 默认 |
| `edge` | 大数字溢出（万亿级）截断策略、单指标、负 delta、超长时间范围 | 变更 mock 返回 |

- **五态由数据驱动，不是模板里的假分支**：沿用 `list-page` §5 的做法，用 mock 接口的返回值切换
  （不结算 → loading / 空数组 → empty / reject → error / 超长数据 → edge），
  并在页面顶部放一个 `⚠ 演示脚手架` 标注的场景切换器。
  **不要**用旧形态的「切容器 `data-state` + CSS 显隐」——那正是「假装」的来源（`references/rules/ui-prototype-standard.md` §5.3）。
- **单区失败不拖垮整屏**：一个图表 error 时，指标卡照常 populated。
- 数值动画（数字跳变）**不能**是数据变化的唯一信号（§5.5）。

---

## 6. 收尾（在 SKILL.md Step 6 清单外追加）

- [ ] 指标行 ≤4，主图表仅 1 个，主次分明
- [ ] 指标卡用 `te-card` > `te-statistic`，千分位/精度走组件属性而非 CSS
- [ ] 指标值全部可溯源，或已加「示例」/「待定」标记——**无第三个来源**
- [ ] 每个拉数区**独立**五态齐全，`error ≠ empty`，且由 mock 返回驱动
- [ ] 图表为自绘 SVG，无图表库、无外链；无完整网格墙；强调色只用于一处高亮
- [ ] delta 不靠颜色单一表意；大数字不被页面指定字号
- [ ] 区域由真组件承载，**未写 `data-ui-role`**（该词表已废止）
- [ ] 壳（`te-sidenav` / `te-tags-view`）是否在本文件内已在 `_notes.md` 说明
- [ ] `<style>` 中只有页面级布局与**图表自建区**，无覆盖组件外观的 CSS，无 `:deep()`
- [ ] `_notes.md` 已记：区域→组件映射、时间范围控件口径、图表自建区的视觉方向、所有「示例/待定」位置、待替换占位
- [ ] 原型落 `<项目根>/prototype/`，命名符合 §3.2（`[Sxx_]<页面名>.vue`）；`_notes.md` 已归档到 `archive-spec/product/ui-*/`
- [ ] **在项目沙箱里构建过并看过五态截图**（`cd prototype && npx vite build`；§6）
