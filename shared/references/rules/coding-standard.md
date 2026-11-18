# 编码规范

> 本规范定义项目编码标准。所有新增/修改代码必须符合本规范。
>
> Vue 组件开发范式参见 references/rules/vue-standard.md。

---

## 一、核心原则

保持简单（KISS）、优先复用、最小修改、向后兼容、单一职责（SRP）。

**禁止**：Breaking Change、修改无关代码、重复实现已有能力、过度设计、调试代码。

---

## 二、TypeScript

**必须**：Strict Mode、`interface`/`type` 声明类型、不允许 `any`、优先 `unknown`、使用泛型、Props/Emits/Expose 带类型。

**禁止**：`any`、`var`、`eval`。

---

## 三、命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 目录 | kebab-case | `order-manage` |
| Vue/TS 文件 | camelCase | `createForm.vue`、`usePagination.ts` |
| 组件名 | PascalCase | `OrderManage` |
| 变量/函数 | lowerCamelCase | `userInfo`、`getList` |
| 函数 | 动词 + 名词 | `updateStatus`、`handleSubmit` |
| 类型/接口 | PascalCase | `ListRow`、`QueryParams` |
| 全局常量 | UPPER_SNAKE_CASE | `SUCCESS_CODE` |
| 局部常量 | lowerCamelCase | `defaultFormData` |

> **命名约定说明**：目录 kebab-case、Vue/TS 文件 camelCase、组件 PascalCase 为团队既定约定，本表为**唯一权威**，其他文档（如 vue-standard）引用本表。

---

## 四、语法与风格

```typescript
// 声明：优先 const，其次 let
const name = 'hello';

// 模板字符串
const text = `${name}-${id}`;

// 对象字面量 + 展开
const merged = { ...defaults, ...overrides };

// 缩进 2 Space，单引号，分号由 Prettier 处理
if (success) {
  loadData();
} else {
  showError();
}

// ❌ var / 字符串拼接 / new Object() / for...in / 魔法数字
```

**函数**：单一职责、≤ 100 行、参数 ≤ 5 个、优先纯函数。禁止深层嵌套（> 3 层）。

---

## 五、Import

```typescript
// 顺序：第三方 → @/ 别名 → 相对路径
import { ref, watch } from 'vue';
import { request } from '@/utils/request';
import { getList } from '@/apis/orderManage/index';
import CreateForm from './modules/createForm.vue';
import { SEARCH_PARAMS } from './constant';

// ❌ import * as api from '@/apis/xxx';        // 通配导入
// ❌ import { something } from 'lodash';        // 非 lodash-es
```

---

## 六、注释

```typescript
/** 公共函数 */
/**
 * @description 获取用户列表
 * @param params 查询参数
 * @returns 用户列表
 */
export function getUserList(params: QueryParams) { ... }

/** @module orderManage */
/** @component 订单管理列表页 */

// ❌ 无意义注释、裸 TODO
```

---

## 七、CSS

小写 kebab-case、2 空格、属性独占行末尾分号、嵌套 ≤ 3 层、`scoped` 隔离、优先 CSS Token。

```css
.form-container {
  padding: var(--te-space-16);
  font-size: var(--te-font-size-b12);
}
/* ❌ 硬编码像素值、不写分号、不写 scoped */
```

---

## 八、安全

用户输入校验 + XSS 防护、敏感信息脱敏、上传校验类型/后缀/大小。
**禁止**：`innerHTML` 拼接用户输入、动态执行脚本。

---

## 九、检查

```bash
npm run ts-check && npm run lint:html && npm run lint:css && npm run build
```

---

## 十、禁止事项

| 类别 | 内容 |
|------|------|
| 类型 | `any`、`var`、`eval`、`for...in` |
| 调试 | `console.log`、`debugger` |
| 结构 | 魔法数字、重复代码、超长函数、深层嵌套 |
| 修改 | 无关模块、公共 API（未经评估） |
| 导入 | 通配 `import *`、非 `lodash-es` 的 lodash |
| 样式 | 硬编码像素、不写 scoped |
