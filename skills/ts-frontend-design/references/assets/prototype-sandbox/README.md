# 原型沙箱（prototype-sandbox）

> **这是什么**：阶段一 UI 原型的**运行壳**。原型本身是 `.vue`，需要有人把它挂起来才能在浏览器里看——
> 这个目录就是那个壳。由独立 UI 子 agent 在产出原型时**拷进项目**，不是插件的运行时依赖。

## 落位

拷到**项目根**（不是 `src/`）：

```text
<项目根>/
├── prototype/                  ← 本节这个目录，拷过来
│   ├── index.html
│   ├── main.ts
│   ├── vite.config.ts
│   ├── tsconfig.json
│   └── Sxx_页面名.vue          ← 原型（UI 子 agent 产出，见 references/rules/ui-prototype-standard.md §3.2）
├── src/                        ← **全程不动**（阶段一不写 src/）
├── vite.config.ts              ← 不动
└── package.json                ← 不新增依赖
```

**为什么在项目根而不是 `src/`**：`references/hard-gate.md`「详细设计门禁」规定设计阶段不得创建 `src/` 下的文件。
原型落在项目根的独立目录，这条门禁**一个字都不用改**——`src/` 直到实现阶段才被碰。
实现时原型 `.vue` **晋升**：移入 `src/views/<module>/index.vue`，按 `references/rules/vue-standard.md` §3.1
补齐 `constant.ts` / `hooks/` / `modules/`，接真 API，删演示脚手架，`prototype/` 里**不留副本**。

## 与项目的关系：照抄，不另立

沙箱用**项目的** `node_modules`（`vite` / `@vitejs/plugin-vue` / `vue` / 组件库都从上级目录解析，
不需要在这里再装一份，也不需要 `package.json`）。用的是项目同版本的 Vue 与编译器——
这正是「跑在项目里」而不是「跑在仿制品里」的意义。

`main.ts` 里组件库的引入路径、主题 CSS、语言包、全局指令，**照项目 `src/main.ts` 抄**。
沙箱自己另挑一套引法，就失去了「验证项目里长什么样」这个唯一目的。

## 怎么跑

```bash
cd prototype
npx vite            # 或 npx vite build 做一次构建检查
```

## 对项目构建与检查的影响

默认**零影响**，但三条要确认（UI 子 agent 在 `_notes.md`「待替换占位」里记结论）：

| 关注点 | 默认情况 | 需要确认的情形 |
|---|---|---|
| 生产构建 | 不影响——Vite 只打包根 `index.html` 引到的东西，沙箱是独立入口 | 项目若自定义了 `build.rollupOptions.input` 多入口，把 `prototype/` 排除 |
| 类型检查 | 不影响——项目 `tsconfig.json` 的 `include` 通常只含 `src/**` | 项目若 `include` 了全仓库，把 `prototype/` 加进 `exclude` |
| Lint | 不影响——同上 | `lint:html` / `lint:css` 若扫全仓库，把 `prototype/` 加进 ignore |

**不进 git**：与旧验证脚手架的纪律一致（`references/rules/ui-prototype-standard.md` §6）——`prototype/` 是阶段一的
临时验证件，实现后即晋升消失。需要项目 `.gitignore` 加一行 `prototype/`。
可追溯性由归档里的 `_notes.md` 承担（它**进** git）。

## 已验证的实测坑

都是这套壳在真机跑出来的，够具体，照抄结论即可：

**无头截图**

- `te-tablebar` 的查询条件区默认收起（靠「更多搜索」展开）。无头里点不了按钮时，
  可以用 URL hash 触发一次 `document.querySelector('.tlws-header-more-btn')?.click()`，
  但要知道下面这条。
- **过渡不会结束**：无头虚拟时间下 CSS 过渡不推进，`v-show` 卡在 `enter-active`，截图仍是收起态。
  处理是抹掉 `transition` / `opacity` / `transform`。
- ⚠ **只压过渡与入场态，绝对不要动 `display`**。`.tlws-form` 是靠 CSS 类做成 flex 的，
  写成 `display: block` 会把整个查询区**压塌成竖排**——这会看起来像原型自身的布局 bug，
  浪费一整轮排查。
- Chrome 无头截图偶发失败时，换一个干净的 `--user-data-dir` 重试即可。
- 不要用 `CommandLine -like '*--headless*'` 去杀 Chrome——会波及同机其他会话的浏览器。

**五态逐屏**

- 在原型里把场景切换器暴露到 `window.__odScenario`（一行，标 `⚠ 演示脚手架`），
  截图脚本就能 `window.__odScenario('empty')` 逐屏驱动，不必靠 DOM 猜测按钮位置。
- 这一行属于「待替换占位」，实现时随其他演示脚手架一起删。

**版本敏感**

- `@tiansu/ts-web-package` < 2.0.0 时组件从 `@tiansu/element-plus` 引入，
  `main.ts` 的引入路径随之改。版本判据见 `skills/ts-components`。
