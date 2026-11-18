---
name: ts-implement
description: "根据已确认的设计文档进行编码实现，严格遵循项目规范，完成后自检。"
user-invocable: true
agent_created: true
when-to-use: "设计文档已确认且设计评审无 Critical 问题，需要按清单编码实现时。"
---

# Goal（目标）

> **路径约定**：本技能内所有以 `references/` 开头的路径，均相对于本 SKILL.md 所在目录（技能根）；文中出现的 `xxx-standard.md` 等规范文件，全文见 `references/rules/` 下的同名文件。

严格按照设计文档编码，一次性通过质量门禁。**不修改设计、不跳过检查、不自行发挥。**

---

# ⛔ 强制门禁（Hard Gate）

遵循 references/hard-gate.md「强制门禁 — 详细设计门禁」。**设计文档未确认 → 立即停止。**

---

# Workflow（工作流程）

## Step 0：前置检查

- [ ] 设计文档已用户确认 + 评审 Approved
- [ ] **例外分支**：若用户已按 `references/hard-gate.md`「三级判定（唯一权威）」表确认**跳过**详细设计/评审，则以「用户确认的改动说明 + 影响文件清单」替代设计文档，并在完成报告中注明「本轮为可跳过路径」——不得以「没有设计文档」为由拒绝执行，也不得借此放宽 `Step 1` 设计遵循门禁
- [ ] 已读 `references/rules/coding-standard.md`、`references/rules/vue-standard.md`
- [ ] 编码涉及组件时，**调用 `ts-components` skill**（Skill tool / `/ts-components`），按其流程执行 `tsweb info <组件名> --format json` 获取准确 Props/Events/Slots，并输出组件使用与配置

## Step 1：设计遵循门禁 ⛔

**此门禁未通过 → 禁止创建/修改任何 `src/` 文件。**

从设计文档逐项提取以下 6 项清单，输出给用户确认。**清单即编码唯一凭据，清单外一律禁止。**

| 清单    | 强制要求                                                         |
| ------- | ---------------------------------------------------------------- |
| L1 文件 | **列出每个文件的完整相对路径（以 src/ 为根）**，如 `src/apis/xxx/index.ts`，不得用 `{m}` 占位 |
| L2 组件 | **列出每个页面每个区域的具体组件名**，非模板示例                 |
| L3 API  | **列出每个接口的函数签名 + URL + Method**，替换实际模块名        |
| L4 类型 | **列出每个 interface 的全部字段名及类型**，禁止 `...` 省略       |
| L5 路由 | **列出实际 path + name + component**，替换实际值                 |
| L6 禁止 | **仅列设计文档中具体出现的**不做的功能；设计文档未提及的功能 → 推定禁止并**随 L1–L6 清单一并请用户确认**，用户确认后才为最终禁止 |

**输出前自检**：如果清单中仍包含 `{m}` / `{M}` / `...` / `同新增` / `等` 等占位或模糊词 → 未完成提取，重新从设计文档提取。

输出格式（以订单管理模块为例）：

```
=== 设计遵循清单 ===
【L1 新增文件】（共 9 个）
  src/apis/orderManage/index.api.ts
  src/apis/orderManage/index.ts
  src/router/modules/orderManage.ts
  src/views/orderManage/index.vue
  src/views/orderManage/constant.ts
  src/views/orderManage/hooks/useBtnHandles.ts
  src/views/orderManage/modules/createForm.vue
  src/views/orderManage/modules/editForm.vue
  src/views/orderManage/modules/detail.vue

【L2 组件】
  列表页 — 搜索区：te-tablebar（search-items）
          表格区：TeModuleTable
          操作按钮：TeTableButtonGroup + ColSettingBtn
  新增弹窗 — te-dialog > te-form > te-input(订单名称) + te-select(状态) + te-date-picker(创建时间)
  编辑弹窗 — te-dialog > te-form > te-input(订单名称) + te-select(状态) + te-date-picker(创建时间)
  详情弹窗 — te-dialog > te-descriptions

【L3 API】（共 6 个）
  getList       — POST /sec/orderManage/page
  getDetail     — POST /sec/orderManage/getById
  createData    — POST /sec/orderManage/add
  editData      — POST /sec/orderManage/update
  deleteData    — POST /sec/orderManage/delete
  getTableColumns — POST /commonConfig/bff/web/v1/tableConfig/orderManage/getTableConfig

【L4 类型】
  ListRow       — { id: string, orderName: string, status: number, amount: number, createTime: string }
  QueryParams   — { pageNum: number, pageSize: number, searchValue?: string, status?: number }
  FormData      — { id?: string, orderName: string, status: number, amount: number }

【L5 路由】
  /orderManage → name: OrderManageList → src/views/orderManage/index.vue

【L6 禁止】
  设计文档明确 Out of Scope：批量导入、模板下载
  设计文档未提及（推定禁止）：排序、导出、批量删除、列拖拽、自定义筛选
```

**发现设计文档遗漏或矛盾 → 停下来确认，禁止自行补全。**

## Step 2：按清单编码

逐文件、逐组件、逐 API 实施。每项对照清单确认 + 组件通过 Skill 确认 API。按 Phase 顺序：API 层 → 路由 → 视图层(常量+hooks+modules) → 列表页。

### 组件选择

设计文档已标注 → 用已标注的。未标注 → 按优先级：`@tiansu/ts-web-package` → `@tiansu/element-plus` → `@/components/` → `modules/`（仅模块内）。禁止 `el-` 前缀。

**使用每个组件前**，调用 `ts-components` skill（Skill tool / `/ts-components`）核实组件真实 API（`tsweb info <组件名> --format json`），获取准确的 Props/Events/Slots。禁止凭记忆编造组件 API，禁止跳过 ts-components skill 直接运行裸 `tsweb` 命令。

### 编码红线

**必须**：`<script setup lang="ts">`、`request` 调用 API、Props/Emits/Expose 带类型、文件命名 kebab-case/camelCase。

**禁止**：`any`、`console.log`、魔法数字、重复代码、清单外代码、无关修改。

## Step 3：格式化 + 检查

```bash
npm run prettier-format
npm run ts-check && npm run lint:html && npm run lint:css && npm run build
```

## Step 4：输出完成报告

新增文件清单 + 用途 + 检查结果（ts-check/lint/build），未通过项说明原因。

---

# Implement Gate（编码门禁）

**设计遵循**：

- [ ] 已输出 L1~L6 清单 + 用户已确认
- [ ] 所有文件/组件/API/类型/路由均来自清单
- [ ] 未实现 L6 中的任何项目

**质量**：

- [ ] 组件 API 通过 `ts-components` skill 确认
- [ ] 无 `any` / `console.log` / `el-` 前缀组件
- [ ] ts-check + lint:html + lint:css + build 全部通过
- [ ] 未修改无关文件

**任一未满足 → 修复后重新全部检查。**
