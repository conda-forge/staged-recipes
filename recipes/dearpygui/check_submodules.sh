#!/usr/bin/env bash
# Verify that the imgui/implot commits pinned in recipe.yaml match the git
# submodule commits recorded in the upstream DearPyGui release tag.
# Run this on every version bump; the autotick bot does not update these pins.
# Requires: gh (authenticated)
set -euo pipefail

recipe="$(dirname "$0")/recipe.yaml"

get_context() {
  # first match only: the context section comes first
  sed -nE "s/^  $1: \"?([^\"]+)\"?$/\1/p" "$recipe" | head -n1
}

version="$(get_context version)"
status=0
for module in imgui implot; do
  pinned="$(get_context "${module}_commit")"
  upstream="$(gh api "repos/hoffstadt/DearPyGui/contents/thirdparty/${module}?ref=v${version}" -q .sha)"
  if [[ "$pinned" == "$upstream" ]]; then
    echo "OK       ${module}: ${pinned}"
  else
    echo "MISMATCH ${module}: recipe pins ${pinned}, v${version} uses ${upstream}"
    status=1
  fi
done
exit "$status"
