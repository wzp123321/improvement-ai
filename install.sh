#!/usr/bin/env bash
# 把仓库里的技能部署到 ~/.workbuddy/skills/
#
# 仓库结构：skills/<name>/ 只放该技能独有文件，公共部分在 shared/references/
# 部署时先把 skills/<name>/ 复制过去，再把 shared/references/ 补进去（不覆盖技能自有同名文件）
set -euo pipefail

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

for src in "${REPO_DIR}"/skills/*/; do
  name="$(basename "${src}")"
  dst="${SKILLS_DIR}/${name}"

  if [ -e "${dst}" ]; then
    mkdir -p "${BACKUP_DIR}"
    mv "${dst}" "${BACKUP_DIR}/${name}"
    echo "backup    ${name}"
    backed=$((backed + 1))
  fi

  cp -r "${src}" "${SKILLS_DIR}/${name}"

  # 注入公共 references：技能自有同名文件优先，不覆盖
  if [ -d "${SHARED}" ]; then
    mkdir -p "${SKILLS_DIR}/${name}/references"
    cp -rn "${SHARED}"/. "${SKILLS_DIR}/${name}/references/" 2>/dev/null || true
  fi

  echo "installed ${name}"
  installed=$((installed + 1))
done

echo
echo "完成：安装 ${installed} 个，备份 ${backed} 个"
[ -d "${BACKUP_DIR}" ] && echo "备份目录：${BACKUP_DIR}"
echo "重启 WorkBuddy 后生效。"
