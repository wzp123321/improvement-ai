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

## 部署

```bash
git clone git@github.com:wzp123321/improvement-ai.git
cd improvement-ai && ./install.sh
```

`install.sh` 把 `skills/` 下每个目录复制到 `~/.workbuddy/skills/`，同名目录先备份到 `~/.workbuddy/skills-backup-<时间戳>/`。

部署后**重启 WorkBuddy** 才会索引新技能。

## 维护

- 改技能：改 `skills/<name>/SKILL.md`，`git push`。
- 本机装好的技能要同步回仓库：`./sync-back.sh`（从 `~/.workbuddy/skills/` 覆盖仓库内同名目录）。
- 新增技能：把目录复制进 `skills/` 再 push。
