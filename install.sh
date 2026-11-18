#!/usr/bin/env bash
# 把仓库里的技能部署到 ~/.workbuddy/skills/
set -euo pipefail

SKILLS_DIR="${HOME}/.workbuddy/skills"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
  echo "installed ${name}"
  installed=$((installed + 1))
done

echo
echo "完成：安装 ${installed} 个，备份 ${backed} 个"
[ -d "${BACKUP_DIR}" ] && echo "备份目录：${BACKUP_DIR}"
echo "重启 WorkBuddy 后生效。"
