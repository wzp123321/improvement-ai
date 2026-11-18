#!/usr/bin/env bash
# 把本机 ~/.workbuddy/skills/ 里仓库已跟踪的技能同步回仓库
#
# 公共 references 在仓库里只存一份（shared/references/），
# 所以同步回来时要剔除与本机文件逐字节相同的公共文件，避免重复入库。
set -euo pipefail

SKILLS_DIR="${HOME}/.workbuddy/skills"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="${REPO_DIR}/shared/references"

for src in "${REPO_DIR}"/skills/*/; do
  name="$(basename "${src}")"
  live="${SKILLS_DIR}/${name}"

  if [ ! -d "${live}" ]; then
    echo "skip      ${name}（本机不存在）"
    continue
  fi

  rm -rf "${src}"
  cp -r "${live}" "${src}"

  if [ -d "${SHARED}" ]; then
    todel=()
    while IFS= read -r rel; do
      rel="${rel#./}"
      f="${src}references/${rel}"
      [ -f "$f" ] || continue
      [ -f "${SHARED}/${rel}" ] || continue
      cmp -s "$f" "${SHARED}/${rel}" && todel+=("$f")
    done < <(cd "$SHARED" && find . -type f)

    if [ ${#todel[@]} -gt 0 ]; then
      rm -f "${todel[@]}"
    fi
    echo "updated   ${name}（剔除公共文件 ${#todel[@]} 个）"
  else
    echo "updated   ${name}"
  fi
done

echo
echo "用 git status 查看差异后提交。"
