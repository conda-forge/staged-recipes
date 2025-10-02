#!/bin/bash
set -euo pipefail
set -x

root="$SRC_DIR/scalable-vs"

# Convert embedded .conda(s) -> .tar.bz2 and extract
for f in "$root"/*.conda; do
  [ -e "$f" ] || continue
  cph transmute "$f" .tar.bz2
  tbz="${f%.conda}.tar.bz2"
  tar xjf "$tbz" -C "$root"
  rm -f "$f" "$tbz"
done

# Find upstream site-packages
sp=$(find "$root/lib" -type d -path "*/python*/site-packages" | head -1 || true)
[ -n "$sp" ] || { echo "ERROR: site-packages not found"; exit 1; }
[ -d "$sp/svs" ] || { echo "ERROR: svs package missing"; exit 1; }

# Target site-packages in build prefix
pyver_dir=$(basename "$(dirname "$sp")")
tsp="$PREFIX/lib/$pyver_dir/site-packages"
mkdir -p "$tsp"

# Copy needed pieces
cp -a "$sp/svs" "$tsp/"
cp -a "$sp"/scalable_vs-*.dist-info "$tsp/"

# Licenses
if [ -d "$root/info/licenses" ]; then
  mkdir -p "$PREFIX/scalable-vs/info"
  cp -a "$root/info/licenses" "$PREFIX/scalable-vs/info/"
fi

# Regenerate info
rm -rf "$PREFIX/info"