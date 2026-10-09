#!/usr/bin/env bash
# Verify that the imgui/implot commits pinned in recipe.yaml match the git
# submodule commits recorded in the upstream DearPyGui release tag.
# The autotick bot does not update these pins on version bumps, so this runs
# as part of the build (see recipe.yaml) and can also be run manually.
#
# Usage: check_submodules.sh [<version> <imgui_commit> <implot_commit>]
# Without arguments, the values are read from the context in recipe.yaml.
set -euo pipefail

if [[ $# -eq 3 ]]; then
  version="$1" imgui_commit="$2" implot_commit="$3"
else
  recipe="$(dirname "$0")/recipe.yaml"
  get_context() {
    # first match only: the context section comes first
    sed -nE "s/^  $1: \"?([^\"]+)\"?$/\1/p" "$recipe" | head -n1
  }
  version="$(get_context version)"
  imgui_commit="$(get_context imgui_commit)"
  implot_commit="$(get_context implot_commit)"
fi

# Shallow, blob-less fetch of the tag: only commit and tree objects, no file contents.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q
git -C "$tmp" fetch -q --depth 1 --filter=blob:none \
  https://github.com/hoffstadt/DearPyGui.git "refs/tags/v${version}"

status=0
for module in imgui implot; do
  pinned_var="${module}_commit"
  pinned="${!pinned_var}"
  upstream="$(git -C "$tmp" ls-tree FETCH_HEAD "thirdparty/${module}" | awk '{print $3}')"
  if [[ "$pinned" == "$upstream" ]]; then
    echo "OK       ${module}: ${upstream}"
  else
    echo "MISMATCH ${module}: recipe pins ${pinned}, v${version} uses ${upstream}"
    status=1
  fi
done

if [[ $status -ne 0 ]]; then
  cat >&2 <<EOF

ERROR: DearPyGui v${version} uses different imgui/implot submodule commits than
the ones pinned in recipe.yaml. Update the *_commit values in the recipe's
context to the upstream commits listed above and recompute the sha256 of each
changed source, e.g.:

  curl -Ls https://github.com/ocornut/imgui/archive/<commit>.tar.gz | sha256sum
  curl -Ls https://github.com/epezent/implot/archive/<commit>.tar.gz | sha256sum
EOF
fi
exit "$status"
