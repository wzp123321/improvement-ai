#!/usr/bin/env bash
# 把仓库里的技能部署到 ~/.workbuddy/skills/
#
# 仓库结构：skills/<name>/ 只放该技能独有文件，公共部分在 shared/references/
# 部署时先把 skills/<name>/ 复制过去，再把 shared/references/ 补进去（不覆盖技能自有同名文件）
#
# 关于 mv 失败：WorkBuddy 运行时会锁住部分技能目录，Windows 下 rename 会 Permission denied。
# 此时降级为文件级覆盖并继续装剩下的 —— 不能让一个目录卡住整批。
set -uo pipefail

SKILLS_DIR="${HOME}/.workbuddy/skills"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="${REPO_DIR}/shared/references"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${HOME}/.workbuddy/skills-backup-${STAMP}"

if [ ! -d "${REPO_DIR}/skills" ]; then
  echo "error: ${REPO_DIR}/skills 不存在" >&2
  exit 1
fi

mkdir -p "${SKILLS_DIR}"

installed=0
backed=0
degraded=""

for src in "${REPO_DIR}"/skills/*/; do
  name="$(basename "${src}")"
  dst="${SKILLS_DIR}/${name}"
  flat=0

  if [ -e "${dst}" ]; then
    mkdir -p "${BACKUP_DIR}"
    if mv "${dst}" "${BACKUP_DIR}/${name}" 2>/dev/null; then
      echo "backup    ${name}"
      backed=$((backed + 1))
    else
      echo "warn      ${name} 目录被占用，改为文件级覆盖（旧版多余文件可能残留）"
      degraded="${degraded} ${name}"
      flat=1
    fi
  fi

  if [ "${flat}" = "1" ]; then
    cp -rf "${src}"/* "${dst}/" 2>/dev/null || { echo "error     ${name} 覆盖失败，跳过" >&2; continue; }
  else
    cp -r "${src}" "${dst}" || { echo "error     ${name} 复制失败，跳过" >&2; continue; }
  fi

  # 注入公共 references：技能自有同名文件优先，不覆盖
  if [ -d "${SHARED}" ]; then
    mkdir -p "${dst}/references"
    cp -rn "${SHARED}"/. "${dst}/references/" 2>/dev/null || true
  fi

  echo "installed ${name}"
  installed=$((installed + 1))
done

echo
echo "完成：安装 ${installed} 个，备份 ${backed} 个"
[ -d "${BACKUP_DIR}" ] && echo "备份目录：${BACKUP_DIR}"
if [ -n "${degraded}" ]; then
  echo "以下技能是文件级覆盖，旧版多余文件仍在（想彻底干净请关掉 WorkBuddy 后重跑）："
  echo "  ${degraded# }"
fi
echo "重启 WorkBuddy 后生效。"
