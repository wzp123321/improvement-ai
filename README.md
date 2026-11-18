# improvement-ai

WorkBuddy 个人技能配置，用于跨机器迁移。换机器后 clone + 跑一次 `install.sh` 即可恢复。

## 技能

| 分组 | 技能 | 作用 |
|---|---|---|
| 开发流水线 | `sdd-orchestrator` | 多智能体编排：需求 → 设计 → 编码 → 评审 → 自测 → 提交 |
| | `ts-overview` | 阶段一：PRD → 后端概设 + 前端概设 + UI 原型 |
| | `ts-design` | 阶段二：概设 → 详细设计 DDD |
| | `ts-design-review` | 设计评审门禁，出 Critical 清单 |
| | `ts-implement` | 阶段三：按设计编码 + 自检 |
| | `ts-code-review` | 阶段四：分级代码审查报告 |
| | `ts-frontend-design` | 独立高保真视觉稿（真组件拼的 Vue SFC） |
| | `ts-components` | 组件库查询与代码生成 |
| 测试 | `ui-test-runner` | 跑 Excel 用例库 → UI 自动化 → 通过/失败报告 |
| 环境 | `project-map` | 仓库索引：路径、启动命令、端口 |
| 工具 | `grill-me` | 反问到底，压力测试方案 |

## 结构

```
skills/<name>/          技能独有文件（SKILL.md + 该技能特有的 references）
shared/references/      7 个 ts 技能共用的一份 rules / templates / assets
install.sh              部署：复制技能 + 注入 shared
sync-back.sh            回同步：本机 → 仓库，自动剔除公共文件
```

ts 系列原先每个技能各带一份完全相同的 `references`（同一份内容复制 7 份），改一处要改七处。现在只存 `shared/` 一份，部署时注入。

公共部分统一到 `shared/references/`，各技能目录里只剩独占文件：`ts-components` 的 `code-generation.md`、`ts-frontend-design` 的 5 个 `recipes/`。

`rules/coding-standard.md` 与 `rules/vue-standard.md` 曾出现两种版本（模块 hook `use{Module}` 与 `useTable` 的分叉），现已统一采用模块 hook 版。

## 部署

```bash
git clone git@github.com:wzp123321/improvement-ai.git
cd improvement-ai && ./install.sh
```

`install.sh` 对每个技能：先复制到 `~/.workbuddy/skills/`（同名目录备份到 `~/.workbuddy/skills-backup-<时间戳>/`），再把 `shared/references/` 注入进去，技能自有同名文件优先、不覆盖。

部署后**重启 WorkBuddy** 才会索引新技能。

注意：仓库里的 `skills/` 不能直接当技能用 —— `references` 是部署时补齐的。

## 维护

| 场景 | 做法 |
|---|---|
| 改某个技能的 SKILL.md | 直接改 `skills/<name>/SKILL.md`，push |
| 改公共规范（rules / templates） | 只改 `shared/references/` 一处，push，重新跑 `install.sh` |
| 本机改完要回流 | `./sync-back.sh`，逐字节相同于 shared 的文件会被自动剔除 |
| 新增技能 | 目录复制进 `skills/`，独有文件留在里面，公共部分并入 `shared/` |
