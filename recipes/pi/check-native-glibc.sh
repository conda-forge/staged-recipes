#!/usr/bin/env bash
# Guard the vendored prebuilt native modules against a future upstream rebuild
# that links a newer glibc than the conda-forge baseline. Every shipped *.node
# must stay within the c_stdlib_version floor advertised through __glibc;
# otherwise the package would install on an old system and fail to load at
# runtime. The baseline is passed in via $GLIBC_BASELINE (set from
# c_stdlib_version in recipe.yaml).
set -euo pipefail

baseline="${GLIBC_BASELINE:-2.17}"
echo "Verifying shipped native modules stay within glibc ${baseline}"

bmaj="${baseline%%.*}"; brest="${baseline#*.}"; bmin="${brest%%.*}"
status=0; found=0
for f in $(find "$PREFIX" -name '*.node' -type f); do
  found=1
  for v in $(objdump -T "$f" 2>/dev/null | grep -oE 'GLIBC_[0-9]+\.[0-9]+' | sed 's/GLIBC_//' | sort -uV); do
    maj="${v%%.*}"; rest="${v#*.}"; min="${rest%%.*}"
    if [ "$maj" -gt "$bmaj" ] || { [ "$maj" -eq "$bmaj" ] && [ "$min" -gt "$bmin" ]; }; then
      echo "FAIL: $(basename "$f") requires GLIBC_${v} (> baseline ${baseline})"
      status=1
    fi
  done
done

[ "$found" -eq 1 ] || { echo "FAIL: no .node files found to verify"; exit 1; }
[ "$status" -eq 0 ] && echo "OK: all native modules are within glibc ${baseline}"
exit "$status"
