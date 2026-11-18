---
name: project-map
description: 用户主力代码仓与运行环境的索引。当用户提到 HLMS、hlms-bi-front、mega-vision、虚拟电厂 / energy-vpp、云音乐 / cloud-music、备课排课 / prepare-lesson、制卷、录入台、数据填报等代号，或需要定位仓库路径、启动命令、端口时使用。
when-to-use: "用户提到项目代号 / 仓库简称，或要启动、定位某个项目时。先查本技能再动手，不要重新问用户路径。"
---

# project-map — 项目索引

路径与命令均为本机实测。用户当次说法优先于本表，冲突时以用户为准并更新本文件。

## 仓库根

| 代号 | 根路径 | 说明 |
|---|---|---|
| HLMS | `D:/workspace/company/hlms-workspace` | 多仓集合，**子仓按分支建目录**，不是 git 切分支 |
| 虚拟电厂 / energy | `D:/workspace/company/virtual-power-plant` | 后端 + 前端同一根 |
| 云音乐 / cloud-music | `D:/workspace/private/collect/cloud-music` | 私人 collect 分组 |
| 测试台账 | `D:/workspace/company/test-workspace` | `INDEX.md` 为环境/用例唯一真相源，账密在 `credentials.local.env` |

HLMS 子仓目录形如 `hlms-bi-front/{master,feature-4.4.0-metric,feature-V4.6.0}`，**进入具体版本目录才是真正的工程根**，不要在子仓一级找 `package.json`。

## HLMS 子仓

| 子仓 | 用途 | 启动 |
|---|---|---|
| `hlms-bi-front` | 数据应用中心 | `npm run dev`；base `/web/hlmsBi`，端口 5174，根路径 302 跳该 base |
| `hlms-dgmp-nodejs` | BFF | 本地 `http://localhost:10060` |
| `hlms-open-pandoc-nodejs` | pandoc-server | — |
| `hlms-data-report-front` | 数据填报前端 | — |
| `hlms-data-report-app-front` | 移动端报表（uni-app） | `npm run dev` = `dev:h5` |
| `hlms-bi-chart-package` | 图表包 | — |
| `hlms-data-governance-front` | 数据治理 | — |
| `hlms-portal-front` | 门户 | — |
| `hlms-facades` | 门面层 | — |
| `nts-dgmp` | DGMP | — |
| `mega-vision` | 大屏 monorepo | pnpm workspace，见下 |

`mega-vision` 是 pnpm monorepo，apps 有 `mega-vision` / `digital-vision` / `hlms-config-vision`：

```
pnpm dev:mega      # @apps/mega-vision
pnpm dev:digital   # @apps/digital-vision
pnpm dev:config    # @apps/hlms-config-vision
pnpm build:mega / build:digital / build:config
pnpm type-check:mega / type-check:digital / type-check:config
```

私服：`pnpm run set-lib` 切内网源，`set-public` 切回公共源；`publish` = build big-screen-render + 发版。

## 虚拟电厂

| 子项目 | 栈 | 关键信息 |
|---|---|---|
| `energy-vpp-service` | Java / Spring Boot / JDK21 | Maven 多模块：`energy-virtual-power-plant-app` + `-api`；parent `energy-service-parent` 4.3.0.AGENT-SNAPSHOT；本仓 4.4.0.YZW.RC1-SNAPSHOT |
| `energy-vpp-web` | Vue3 + Vite + TS | `npm run dev` → 端口 9999，host 0.0.0.0；`npm run build` = gen + ts-check + vite build |

- 后端常驻 `18899`，临时验证 `18888`。
- `energy-common-ddd` 跟随平台 4.3.0 线，**禁止用 `${project.version}`**（Nexus 上无此版本）。
- 前端代理 `http://192.168.50.176:10130`。

## 加密环境

本机文档类文件被亿赛通加密，读写规矩见 `esafenet-plaintext-convert` 技能与 `MEMORY.md`，此处不重复。

## 维护

- 本文件是纯文本，**换机器直接拷 `~/.workbuddy/skills/project-map/` 即可**。
- 新增项目只加表格行；路径变了改值，不留「曾改为」的记录。
