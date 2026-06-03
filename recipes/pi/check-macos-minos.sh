#!/usr/bin/env bash
# Verify every shipped macOS native module's minimum-macOS version
# (LC_BUILD_VERSION "minos" or the older LC_VERSION_MIN_MACOSX "version") is
# within the deployment-target floor the package advertises through __osx
# ($MACOS_BASELINE, taken from c_stdlib_version in recipe.yaml). Otherwise the
# package could install on a macOS older than a shipped binary supports and then
# fail to load it. This is the macOS analogue of check-native-glibc.sh.
set -euo pipefail

baseline="${MACOS_BASELINE:-11.0}"
echo "Verifying shipped native modules target macOS <= ${baseline}"

# Portable major.minor "greater than" — macOS /usr/bin/sort has no -V.
ver_gt() {
  local amaj="${1%%.*}" bmaj="${2%%.*}" amin bmin
  amin="${1#*.}"; [ "$amin" = "$1" ] && amin=0; amin="${amin%%.*}"
  bmin="${2#*.}"; [ "$bmin" = "$2" ] && bmin=0; bmin="${bmin%%.*}"
  [ "$amaj" -gt "$bmaj" ] || { [ "$amaj" -eq "$bmaj" ] && [ "$amin" -gt "$bmin" ]; }
}

status=0; found=0
for f in $(find "$PREFIX" -name '*.node' -type f); do
  while IFS= read -r v; do
    [ -n "$v" ] || continue
    found=1
    if ver_gt "$v" "$baseline"; then
      echo "FAIL: $(basename "$f") targets macOS ${v} (> deployment target ${baseline})"
      status=1
    fi
  done <<EOF
$(llvm-objdump --macho --all-headers "$f" 2>/dev/null | awk '
  /cmd LC_BUILD_VERSION/      { m="b" }
  /cmd LC_VERSION_MIN_MACOSX/ { m="v" }
  m == "b" && $1 == "minos"   { print $2; m="" }
  m == "v" && $1 == "version" { print $2; m="" }
')
EOF
done

[ "$found" -eq 1 ] || { echo "FAIL: no .node with a macOS version load command found"; exit 1; }
[ "$status" -eq 0 ] && echo "OK: all native modules target macOS <= ${baseline}"
exit "$status"
