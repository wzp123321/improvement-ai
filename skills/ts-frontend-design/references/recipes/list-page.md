# 屏型配方：列表管理页（List / CRUD）

> 挂在 `ts-frontend-design` 下的**屏型配方**，不单独触发；由该技能的 Step 0 按屏型取用。
> 适用「XX 列表 / XX 管理 / XX 查询页 / 增删改查」这类**默认中后台页**。
> 源：**非上游抽取**——OpenDesign 182 份配方里没有 CRUD 列表页。本配方由
> `references/rules/ui-prototype-standard.md` §3.3 骨架 + §5 五态 + §8 权限显隐 + §9 区域→组件映射编写。
>
> **2026-09-10 形态变更**：原型由「自包含 HTML」改为「真 `te-*` 组件组合的 Vue 3 SFC」。
> 本配方随之改写——区域不再靠 `data-ui-role` 词表标注，**区域就是组件本身**；值源改为组件库主题。
> 试验件见 `archive-spec/product/ui-V3.1.0_I2_设备台账列表/`。

---

## 0. 先判定

| 输入 | 判定 |
| --- | --- |
| 「XX 列表 / 管理页 / 查询 / 增删改查」 | ✅ 用本配方 |
| 「概览 / 首页指标 / 驾驶舱」 | ❌ 改走 `references/recipes/dashboard.md` |
| 「审批流 / 工单流转」 | ⚠ 列表 + 状态机，本配方管列表部分；状态机显隐见 §6 |

**这是 Te 中后台的默认屏型**——没有明确理由时，你要做的大概率就是它。§3.3 已固定节奏，**禁止每页发明布局**：

```text
页面标题(te-page-header) → 查询区(te-tablebar) → 工具条(te-tablebar #suffix) → 表格(te-module-table) → 分页(表格内置)
新增 / 编辑 / 删除 → 弹窗(te-dialog > te-form)
详情 → te-descriptions
```

---

## 1. 值源与组件核实

- **值源 = 组件库主题**。不填 `:root`、不用 `--p-*`、不抄 tokens 快照，**不在 `<style>` 里写颜色/字号/圆角**（`references/rules/ui-prototype-standard.md` §7）。
- 页面级布局间距取 `--te-space-*` 档位，**不写随机 px**。
- **数字列**（金额、数量、比率）的对齐与等宽数字**由列定义 / 组件属性表达**，不写 CSS（`tabular-nums`、右对齐是表格组件的能力）。
- 组件的真实 Props 与 Events 走 `ts-components`，`tsweb info` / `doc` / `demo` 核实，**禁止凭记忆**。
- **列表数据必须走 `:request-api`**，不用静态 `:data`（`references/rules/ui-prototype-standard.md` §5.2；依据见 §5）。

**本屏型必查的 craft 维度**：

| 维度 | 文件 | 本屏型在哪用 |
| --- | --- | --- |
| `state-coverage` | `references/assets/open-design/craft/state-coverage.md` | 列表五态 + 行内操作态（主用，见 §5） |
| `laws-of-ux` | `references/assets/open-design/craft/laws-of-ux.md` | 查询条件可见性、操作列位置、分页信息量 |
| `accessibility-baseline` | `references/assets/open-design/craft/accessibility-baseline.md` | 表格语义、状态列不靠颜色单一表意 |

---

## 2. 骨架与区域 → 组件

真组件形态下映射**就在模板里**，不再需要词表（`references/rules/ui-prototype-standard.md` §9.1）：

| 区域 | 组件 | 承载 |
| --- | --- | --- |
| 页面标题 | `te-page-header`（+ `#extra`） | 标题 / 副标题 / 主操作 |
| 查询区 | `te-tablebar` + `#searchList` | 关键字 + 条件控件 |
| 工具条 | `te-tablebar` + `#suffix` | 批量操作 / 导出 / 下载模板 |
| 数据表格 | `te-module-table` | 选择列 / 序号 / 内容列 / 操作列 / 分页 |
| 行主标识 | 具名槽 `#<prop>` → `te-link` | 可点进详情的主字段 |
| 行状态 | 具名槽 `#<prop>` → `te-tag` | 语义色 + 文字 |
| 行操作 | 具名槽 `#operation` → `te-table-button-group` | 查看 / 编辑 / 启停 / 删除 |
| 空态 | `te-module-table` 的 `#empty` 槽 | 见 §4（会一并替换内置插图，需权衡） |
| 加载失败 | `te-result` | 独立于空态，可重试 |
| 二次确认 | `TeMessageBox.confirm` | 危险操作；文案写明后果 |
| 新增 / 编辑 | `te-dialog` > `te-form` | — |
| 详情 | `te-descriptions` | — |

顺序即 §3.3 节奏，**不要重排**。**具名槽名 = 列 `prop`**（`TableColumn` 按 `item.prop` 取槽）。

---

## 3. 各区域规格

### 3.1 查询区（`te-tablebar` + `#searchList`）

- **可见条件 ≤ 4 个**。超过 4 个 → 常用 4 个留在展开区，其余由组件自带的「更多搜索」承载。
- 查询与重置成对出现；重置不清空到"未查询"以外的状态。
- 时间范围是高频条件，**就地可见**，不藏进「更多搜索」。
- ⚠ **组件不给 `#searchList` 内的布局**（`.tlws-form-con` 只有 `flex:1`），插入的控件默认竖排铺满整行。
  横排是**页面自己的事**：包一个页面自有容器（flex + wrap + gap），**不要 `:deep()` 进组件内部**。
  这是页面级布局，不违反红线 #3。可复制片段见 §8。

### 3.2 工具条（`te-tablebar` + `#suffix`）

- 主操作（新增）每屏 **≤ 1** 个，用主色；其余用次按钮。主操作放 `te-page-header` 的 `#extra` 更常见。
- **批量操作按钮在未选中行时禁用**——不要点了才提示"请先选择"（`references/rules/ui-prototype-standard.md` §8「不允许的动作不做入口」）。
  选中数由 `@selection-change` 维护（该事件在 `te-module-table` 上可用：组件把外部监听器与自身的 handler 合并，不是覆盖）。
- 危险操作（删除、停用）独立 `danger` 语义 + 二次确认，**不用主色顶替**（§8）。

### 3.3 表格（`te-module-table`）

- **列数 ≤ 7–8**。超过则横向滚动，且操作列固定（`show-operation-column-spread` 等由组件属性控制）。
- 列对齐：文本左对齐，**数字右对齐**，状态与操作居中或左对齐（全表统一，不逐列随意）。
- **`ColumnProps.checked` 是必填**——漏掉会导致内容列整列不渲染。所有列都要给。
- 状态列用**语义色 + 文字**，颜色不能是唯一信号（色盲与黑白打印会失效）。
- 长文本列**截断 + 提供查看全文**（悬停或点开详情）——这是 `edge` 态的落点。
- 行内操作放行尾操作列；**行内不用主色**，主色留给页面级主按钮（`hifi-craft.md` §3 accent ≤ 2/屏）。
- 表头固定、行 hover 反馈、选中行浅底——**均为组件内置**，页面不写样式。

### 3.4 分页（`te-module-table` 内置）

- 分页由组件内置，**显示总条数**由 `total` 决定——只给页码，用户无法判断数据规模，也无法判断筛选是否生效。
- 每页条数可切换；切换后回到第 1 页（组件内置行为）。
- 筛选条件变化后**回到第 1 页**（停留在第 7 页会导致"空结果"的假象）。
- 查询 / 刷新 / 重置调**暴露出来的** API（`getTableList()` 等），**不重建组件**——重建会丢掉「更多搜索」展开状态与已勾选行。

---

## 4. ⚠ 三种"没有数据"必须分开

`references/rules/ui-prototype-standard.md` §5.1 要求 `error ≠ empty`。列表页还要再分一层——**"空"有三种，文案与出路都不同**：

| 情形 | 含义 | 实现位置 | 文案与出路 |
| --- | --- | --- | --- |
| **从未有数据** | 业务上一条都没有 | `#empty` 槽 | 讲人话 + 给主操作入口（「新建第一条…」） |
| **筛选后无结果** | 有数据，条件把它们排除了 | `#empty` 槽 | 「没有符合当前条件的数据」+ 给**清空筛选**入口，**不是**"新建" |
| **请求失败** | error | 表格外 `te-result`（`v-if`） | 出了什么 + 可知原因 + 能做什么（重试） |

把筛选无结果做成"新建第一条"是最常见的错误——用户明明有数据，系统却让他去新建。

> `#empty` 槽**替换的是整块空状态内容**，内置插图会一并消失。是否接受丢失插图需明确决定，并写进 `_notes.md` 未决问题。
> 错误态**不要**塞进 `#empty`——它属于表格之外，用 `te-result` 单独承载并让表格 `v-if` 让位。

---

## 5. 状态

列表页是**重度拉数**屏型。**五态由数据驱动，不是模板里的假分支**：

| 状态 | 怎么产生 |
| --- | --- |
| `loading` | 用组件内置加载态：mock 接口**故意不结算**即可看到，不需要自建转圈 |
| `empty` | 接口返回 `{ rows: [], total: 0 }`；按 §4 三分支走 |
| `error` | 接口 reject / `:request-error` 回调；按 §4 三分支走，与 empty 视觉文案都不同 |
| `populated` | 默认态 |
| `edge` | 超长文本截断、单条、万级条数（分页表现）、超长枚举、空字段（用「—」不用 0 顶替） |

**为什么不能用静态 `:data` 假装五态**：静态数据绕过 `useTable` 管线，会让**操作列整列空白、分页完全不出现、序号列无数字**——三处都不报错，只是安静地空掉。
必须走 `:request-api`，契约 `api(params) → Promise<{ data: { rows, total } }>`，`params = { ...筛选条件, ...initParam, pageNum, pageSize }`。
`total: 0` 能通过组件的真值判断（`"0"` 是非空字符串），空列表走正常分支，不会误入兜底。
**筛选必须真实生效**：空态由筛选逻辑算出，不是模板里的假分支。完整依据见 `references/rules/ui-prototype-standard.md` §5.2。

行内控件态齐全：`hover` / `focus-visible` / `active` / `disabled` / `loading`——**均由组件库提供**，页面不自建（§5.4）。

---

## 6. 权限与显隐 `references/rules/ui-prototype-standard.md` §8

- 按钮的**显隐 / 禁用必须与后端概设权限矩阵一致**。
- **状态机不允许的动作不做入口**——不出现"点了才报错"的按钮。行操作按钮组按行状态**动态生成**（如已停用设备不出现「停用」，改为「启用」）。
- 全站同动作同词；按钮文案 = **动词 + 对象**（「新增设备」优于「新增」）；UI 中文业务词；**emoji 不作功能图标**。

---

## 7. 收尾（在 SKILL.md Step 6 清单外追加）

- [ ] 骨架符合 §3.3 节奏（标题 → 查询 → 工具条 → 表格 → 分页），未自创布局
- [ ] 区域由真组件承载，**未写 `data-ui-role`**（该词表已废止）
- [ ] 查询条件 ≤ 4 个可见，超出由「更多搜索」承载
- [ ] `#searchList` 内的横排包在**页面自有容器**里，未用 `:deep()`
- [ ] 表格列 ≤ 8，每列都带 `checked: true`
- [ ] **走 `:request-api`**，未用静态 `:data`
- [ ] 数字列右对齐 + 等宽数字（由列定义/组件属性表达，未写 CSS）；状态列语义色 + 文字
- [ ] 分页显示总条数；筛选变化后回到第 1 页；查询/刷新/重置走暴露 API 而非重建
- [ ] **三种"没有数据"已分别实现**：从未有 / 筛选无结果 / 请求失败——文案与出路各不相同
- [ ] 批量操作按钮在未选中时禁用；危险操作 danger + 二次确认（文案写明后果）
- [ ] 权限显隐与后端概设矩阵一致；无状态机外动作入口
- [ ] 行内操作不用主色；accent ≤ 2/屏、主按钮 ≤ 1
- [ ] `<style>` 中**只有页面级布局**，无颜色/字号/圆角，无 `:deep()`
- [ ] 原型落 `<项目根>/prototype/`，命名符合 §3.2（`[Sxx_]<页面名>.vue`）；`_notes.md` 已归档到 `archive-spec/product/ui-*/`，并记区域→组件映射、待替换占位与未决问题
- [ ] **在项目沙箱里构建过并看过五态截图**（`cd prototype && npx vite build`；§6）

---

## 8. 可复制片段：条件区横排（页面级布局）

```vue
<template #searchList>
  <div class="query-row">
    <te-select class="query-field" v-model="filters.siteId" placeholder="所属站点" clearable>
      <te-option v-for="s in SITE_OPTIONS" :key="s.value" :label="s.label" :value="s.value" />
    </te-select>
    <te-date-picker class="query-field query-field--range" v-model="range" type="daterange"
      start-placeholder="起始" end-placeholder="截止" value-format="YYYY-MM-DD" />
  </div>
</template>
```

```css
<style scoped>
/* 条件区横排。只作用于本页自己的元素，不进组件内部（不用 :deep）。
   左右 24px 对齐组件库 .tlws-form-btns-row 的内边距。 */
.query-row { display: flex; flex-wrap: wrap; gap: var(--te-space-16); padding: 0 24px; }
.query-field { width: 200px; }
.query-field--range { width: 280px; }
</style>
```

> 这是**页面级布局**，与 `.device-ledger` 同类，不违反红线 #3。
> 出处：`archive-spec/product/ui-V3.1.0_I2_设备台账列表/`（待团队确认是否作为标准条件区排布，见该目录 `_notes.md` 未决 ③）。
