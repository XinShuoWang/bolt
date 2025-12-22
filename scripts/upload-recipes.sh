#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
RECIPES_DIR="${SCRIPT_DIR}/conan/recipes"

recipes=(
  "fizz/2022.10.31.00"
  "wangle/2022.10.31.00"
  "celeborn-cpp-client/main-20251212"
)

for recipe in "${recipes[@]}"; do
  name="${recipe%%/*}"
  version="${recipe#*/}"
  printf 'name=%s, version=%s\n' "$name" "$version"
  pushd "${RECIPES_DIR}/${name}/all"
  conan create . --name "$name" --version "$version" --build=missing
  conan upload "${name}/${version}" -r test --confirm
  popd
done