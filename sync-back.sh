#!/usr/bin/env bash
# 把本机 ~/.workbuddy/skills/ 里仓库已跟踪的技能同步回仓库
set -euo pipefail

SKILLS_DIR="${HOME}/.workbuddy/skills"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for src in "${REPO_DIR}"/skills/*/; do
  name="$(basename "${src}")"
  live="${SKILLS_DIR}/${name}"
  if [ ! -d "${live}" ]; then
    echo "skip      ${name}（本机不存在）"
    continue
  fi

  if diff -rq "${src}" "${live}" >/dev/null 2>&1; then
    echo "same      ${name}"
    continue
  fi

  rm -rf "${src}"
  cp -r "${live}" "${src}"
  echo "updated   ${name}"
done

echo
echo "用 git status 查看差异后提交。"
