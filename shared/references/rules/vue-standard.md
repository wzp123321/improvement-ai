# Vue 开发规范

> 本规范定义项目 Vue 3 开发的结构标准、组件范式、状态管理及设计原则。
>
> 适用于 ts-design、ts-implement、ts-code-review 阶段。

---

## 一、项目目录结构

```
src/
├── apis/                        # API 层
│   ├── types.ts                 # 通用响应类型（CommonReturn、CommonReturnList 等）
│   ├── common/                  # 公共 API（表格列配置等）
│   └── {moduleName}/
│       ├── index.api.ts         # 模块类型定义（Row / QueryParams / FormData）
│       └── index.ts             # API 函数（getList / getDetail / createData / editData / deleteData）
│
├── views/{moduleName}/          # 视图层（按领域模块组织）
│   ├── index.vue                # 列表页（路由入口）
│   ├── constant.ts              # 模块常量（SEARCH_PARAMS / TABLE_PARAMS / DEFAULT_FORM_DATA）
│   ├── hooks/
│   │   └── useBtnHandles.ts     # 操作按钮逻辑（新增/编辑/详情/删除）
│   ├── modules/                 # 模块内子组件
│   │   ├── createForm.vue       # 新增表单
│   │   ├── editForm.vue         # 编辑表单
│   │   └── detail.vue           # 详情展示
│   └── components/              # 模块内私有组件（可选）
│
├── router/modules/              # 路由（自动注册，新增文件即生效）
│   └── {moduleName}.ts
│
├── hooks/                       # 全局复用 Hooks
│   ├── useLoading.ts            # loading 状态
│   └── usePagination.ts         # 分页参数（pageNum / pageSize / orders）
│
├── store/                       # Pinia Store（全局状态）
├── utils/                       # 工具函数
│   ├── request.ts               # 统一请求层（Gateway → DH → AES → Token → Axios）
│   └── message.ts               # 消息提示封装
├── constant/                    # 全局常量
│   └── index.ts                 # SUCCESS_CODE 等
└── components/                  # 全局布局组件（Layout 等）
```

---

## 二、架构分层

```
┌─────────────────────────────────────────┐
│  View 层（views/{module}/）              │
│  index.vue / createForm / editForm /     │
│  detail                                 │
│  职责：UI 渲染、事件绑定、用户交互        │
├─────────────────────────────────────────┤
│  State 层（hooks/ + composables）        │
│  usePagination / use{Module} / ref      │
│  职责：组合业务逻辑、管理页面状态         │
├─────────────────────────────────────────┤
│  API 层（apis/{module}/）                │
│  index.api.ts（类型）+ index.ts（函数）  │
│  职责：数据获取、接口调用                │
├─────────────────────────────────────────┤
│  Infrastructure 层                       │
│  utils/request.ts / constant/ / types.ts │
│  职责：HTTP 通信、认证加密、基础工具      │
└─────────────────────────────────────────┘
```

**依赖方向**：View → State → API → Infrastructure（严格单向，禁止反向或跨层）

---

## 三、模块结构规范

### 3.1 标准模块结构

新增业务模块时，按以下结构创建文件：

```
src/
├── apis/{moduleName}/
│   ├── index.api.ts         # 类型：Row / QueryParams / FormData
│   └── index.ts             # API：getList / getDetail / createData / editData / getTableColumns
├── router/modules/
│   └── {moduleName}.ts      # 路由配置
└── views/{moduleName}/
    ├── index.vue            # 列表页
    ├── constant.ts          # 常量
    ├── hooks/
    │   ├── use{Module}.ts   # 模块数据编排（列表 / 分页 / loading 唯一数据源）
    │   └── useBtnHandles.ts # 操作按钮逻辑
    └── modules/
        ├── createForm.vue   # 新增 Dialog
        ├── editForm.vue     # 编辑 Dialog
        └── detail.vue       # 详情 Dialog
```

### 3.2 跨模块依赖规则

| 依赖类型 | 允许 | 方式 |
|----------|------|------|
| 路由跳转 | ✅ | `router.push({ name: 'OtherModuleList' })` |
| 共享类型 | ✅ | 从 `@/apis/types` 导入 |
| 共享 Hook | ✅ | 从 `@/hooks/` 导入 |
| 全局组件 | ✅ | 从 `@/components/` 导入 |
| **私有组件** | ❌ | 禁止跨模块 import modules/ 下组件 |
| **私有 Hook** | ❌ | 禁止跨模块 import hooks/useBtnHandles |

---

## 四、组件开发范式

### 4.1 列表页（index.vue）

**标准模板**：

```vue
<script lang="ts" setup>
import { ref } from 'vue';
import type { ListRow } from '@/apis/{moduleName}/index.api';
import { use{Module} } from './hooks/use{Module}';
import ListTable from './modules/listTable.vue';
import CreateForm from './modules/createForm.vue';

defineOptions({ name: '{Module}Management' });

// 列表状态：数据 / 分页 / loading 由模块 hook 收口（hook 内部复用全局 usePagination）
const {
  listRows, listLoading, listTotal,
  listPageNum, listPageSize, pageSizes,
  loadList, changeListPage, changeListPageSize, handleListRefresh,
} = use{Module}();

// 弹框组件实例（用于调用其 open 方法）
const formRef = ref<InstanceType<typeof CreateForm>>();
</script>
```

**关键约定**：
- 列表数据 / loading / 总条数由**模块内 hook**（`hooks/use{Module}.ts`）统一收口，子组件只做展示
- 分页参数一律复用全局 `usePagination`，**不手动维护** `pageNum` / `pageSize`
- 父组件只做「事件 → 弹框 / 刷新」的转发编排；增删改后调用 hook 暴露的 load 方法刷新

### 4.2 新增表单（createForm.vue）

**关键约定**：
- 通过 `defineExpose({ open, formVisible })` 暴露给父组件
- 父组件调用 `ref.open()` 打开，子组件 emit `success` / `cancel`
- 表单校验使用 te-form rules
- 提交中按钮 `:loading` 防重复

### 4.3 编辑表单（editForm.vue）

**关键约定**：
- 通过 `defineExpose({ formVisible, editId })` 暴露给父组件
- watch editId 变化 → 自动调 getDetail → 回填表单
- 其余与新增表单一致

### 4.4 详情（detail.vue）

**关键约定**：
- 通过 `defineExpose({ detailId })` 暴露，父组件设置 detailId 触发加载
- 使用 te-descriptions 只读展示
- 加载中使用 v-loading，失败 message.error + 关闭

### 4.5 组件选择优先级

按顺序选取，优先使用排位靠前的组件：

| 优先级 | 来源 | 示例 | 约束 |
|--------|------|------|------|
| **1 组件库** | `@tiansu/ts-web-package` | TeModuleTable、TeTableButtonGroup、te-tablebar、ColSettingBtn | 跨模块自由使用 |
| **2 组件库** | `@tiansu/element-plus` | te-dialog、te-descriptions、te-form、te-input、te-select、te-button | 跨模块自由使用 |
| **3 全局组件** | `@/components/` | Layout、CommonDialog | 跨模块自由使用 |
| **4 模块内组件** | `modules/` | createForm、editForm、detail | **仅允许模块内使用，禁止跨模块引用** |

**⛔ 禁止使用 `el-` 前缀组件**。本项目使用 `@tiansu/element-plus`（`te-` 前缀）。

> **来源判定**：优先级 1（`@tiansu/ts-web-package`）与优先级 2（`@tiansu/element-plus`）的选择由 ts-web-package **版本号**决定（≥2.0.0 用 ts-web-package，<2.0.0 用 element-plus），判定规则见 `ts-components` 技能，以其为唯一权威；本表优先级仅在已定来源内比较。

> **API 核实**：选择或使用组件库组件前，须通过 `ts-components` skill（Skill tool）核实组件真实 API（`tsweb info <组件名> --format json`），禁止凭记忆编造 Props/Events/Slots。

### 4.6 状态覆盖

每个页面/组件必须处理以下四种状态：

| 状态 | 实现 |
|------|------|
| Loading | TeModuleTable 内置骨架屏 / v-loading |
| Empty | TeModuleTable 内置空状态 |
| Error | message.error 提示 |
| Data | 正常展示 |

---

## 五、状态管理规范

### 5.1 状态存放决策

```
状态需要跨组件共享吗？
├── 否 → 组件内 ref/reactive
└── 是 → 需要跨页面共享吗？
    ├── 否 → Composable（useXxx）
    └── 是 → Pinia Store
```

### 5.2 模块级状态（标准模式）

**单个业务模块不创建 Pinia Store**，使用以下组合：

| 状态 | 存放位置 | 示例 |
|------|----------|------|
| 列表数据/loading/总条数 | 模块 hook `use{Module}` | `siteRows`、`siteLoading`、`siteTotal` |
| 分页参数 | `usePagination` | `paginationParams`、`setPage`、`setPageSize` |
| 操作按钮逻辑 | useBtnHandles | `operateBtns`、`operateRow` |
| Dialog 开关 | 组件内 ref | `createFormVisible` |
| 表单数据 | 表单组件内 ref | `formData` |

### 5.3 Pinia Store（跨页面共享）

仅在以下场景创建 Store：
- 用户登录信息 / 权限
- 全局配置
- 跨页面共享状态

使用 Setup Store 语法：

```typescript
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useXxxStore = defineStore('xxx', () => {
  const data = ref<Item[]>([]);
  const loading = ref(false);

  const activeItems = computed(() => data.value.filter(i => i.status === 1));

  async function fetchData() {
    loading.value = true;
    try {
      // API call
    } finally {
      loading.value = false;
    }
  }

  return { data, loading, activeItems, fetchData };
});
```

---

## 六、API 层规范

### 6.1 类型定义（index.api.ts）

```typescript
// 列表行（与表格数据一致）
export interface ListRow {
  id?: string | number;
  name?: string;
  // ...
}

// 查询参数
export interface QueryParams {
  pageNum?: number;
  pageSize?: number;
  searchValue?: string;
  [key: string]: unknown;
}

// 表单提交数据
export interface FormData {
  id?: string | number;
  name?: string;
  // ...
}
```

### 6.2 API 函数（index.ts）

```typescript
import { request } from '@/utils/request';
import type { QueryParams, FormData, ListRow } from './index.api';
import type { CommonResponseType, CommonReturnList } from '../types';

export const getList = (data: QueryParams): CommonResponseType<CommonReturnList<ListRow>> =>
  request({ url: '/sec/{moduleName}/page', method: 'post', data });

export const getDetail = (id: string | number): CommonResponseType<ListRow> =>
  request({ url: '/sec/{moduleName}/getById', method: 'post', data: { id } });

export const createData = (data: FormData): CommonResponseType =>
  request({ url: '/sec/{moduleName}/add', method: 'post', data });

export const editData = (data: FormData): CommonResponseType =>
  request({ url: '/sec/{moduleName}/update', method: 'post', data });

export const getTableColumns = (data: { tableCode: string }): CommonResponseType =>
  request({ url: `/commonConfig/bff/web/v1/tableConfig/${data.tableCode}/getTableConfig`, method: 'post' });
```

**约定**：
- Method 统一 POST
- URL 前缀 `/sec/{moduleName}/`
- 所有函数通过 `request` 调用，禁止直接使用 axios
- 响应类型使用 `CommonResponseType` / `CommonReturnList<T>`

---

## 七、编码约定速查

### 命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 目录 | kebab-case | `order-manage` |
| Vue/TS 文件 | camelCase | `createForm.vue`、`usePagination.ts` |
| 组件名 | PascalCase | `OrderManage` |
| 变量/函数 | lowerCamelCase | `queryParams`、`getList` |
| 类型/接口 | PascalCase | `ListRow`、`QueryParams` |
| 常量 | UPPER_SNAKE_CASE | `SEARCH_PARAMS`、`SUCCESS_CODE` |

> 命名权威见 `references/rules/coding-standard.md` 命名表，本表为速查引用。

### 必须

- `<script setup lang="ts">`
- Composition API
- 通过 `request` 调用 API
- 使用 `@tiansu/ts-web-package` / `@tiansu/element-plus` 组件
- defineEmits / defineProps 带类型
- defineExpose 暴露组件方法

### 禁止

- `any` 类型
- `console.log`（生产代码）
- `el-` 前缀组件
- Options API
- 直接使用 axios / fetch
- 魔法数字
- 重复代码
- 跨模块引用私有组件/Hook
