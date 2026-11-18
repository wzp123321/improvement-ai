# 代码生成规范

## 红线（必须遵守）

### 1. 禁止手写图标 path

不自行编写**图标**的 `<svg>`、`<path>` 代码。图标需求通过组件的 `icon` prop 或 `icon` slot 实现，图标名从 `tsweb info` 返回的合法值中选取。如果组件不支持自定义 icon，则不添加图标。

> **例外：自建区域**。组件库未覆盖的自建区域——图表、画布、时间轴定制、大屏——**可以自绘 SVG**，按 `references/rules/hifi-craft.md` §5 P0-3：等线 1.6–1.8px 描边 + `currentColor`。**图标仍然一律走组件**，自绘通道不适用于图标。

```
错误：<te-button><svg><path d="M18 8A6..."/></svg></te-button>
正确：<te-button icon="warning" />
正确：<te-button><template #icon><te-icon name="warning" /></template></te-button>
```

### 2. 修饰词通过 Props 表达，不做自定义 UI

用户说的口语化表达是 Props 语义，不是让你手动画出对应效果：

| 用户说法 | 含义 | 实现 |
|---------|------|------|
| "告警按钮" | 告警样式的按钮 | `<te-button type="warning">` |
| "成功提示" | 成功状态的提示 | `<te-alert type="success">` |
| "主要按钮" / "主按钮" | 主要操作按钮 | `<te-button type="primary">` |
| "危险操作" | 危险样式的按钮 | `<te-button type="danger">` |
| "加载中" | 加载状态 | 加 `loading` prop |
| "禁用" / "不可用" | 禁用状态 | 加 `disabled` prop |
| "圆角" | 圆角样式 | 加 `round` prop |

先查 `tsweb info` 确认该 prop 是否存在，存在就用 prop，不存在才考虑样式。

### 3. 默认样式不需要覆盖

如果用户没有明确要求特定颜色、尺寸、间距、圆角等样式，使用组件默认样式，不在 `<style>` 中写额外 CSS。

```
错误：<te-button class="custom-btn" type="warning"> 外加 .custom-btn { color: #xxx; background: #xxx; ... }
正确：<te-button type="warning">
```

`<te-button type="warning">` 已经自带告警配色，不需要覆盖 `color` 或 `background`。

### 4. Demo 优先

`tsweb demo` 返回的官方示例是最可靠的代码起点。Demo 中的用法优先于你的猜测。如果 Demo 中没出现的用法，确认 `tsweb info` 中有对应 Prop 才使用。

### 5. 不编造不存在的 Props

如果你想调整组件的外观或行为，先查 `tsweb info` 中是否有对应的 prop：

| 想要的效果 | 先查 prop | 没有就别写 |
|-----------|----------|-----------|
| 改变尺寸 | `size` | ✗ 不硬编码 width/height |
| 圆角 | `round` / `circle` | ✗ 不硬编码 border-radius |
| 改变颜色 | `type` / `color` | ✗ 不硬编码 color/background |
| 朴素风格 | `plain` | ✗ |
| 文字按钮 | `text` / `link` | ✗ |
