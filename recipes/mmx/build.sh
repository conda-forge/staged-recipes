#!/usr/bin/env bash

set -euxo pipefail

packages=$(
  make -s -f Makefile.in -f - print-ALL_PACKAGES <<'EOF'
print-ALL_PACKAGES:
	@printf '%s\n' '$(ALL_PACKAGES)'
EOF
)

# mmxlight/build/Makefile.am contains 'mmx_light_PATCH_1 = \#\#\# BEGINNING OF MMXPATCH',
# leading to
#     build/Makefile.am:79: warning: escaping \# comment markers is not portable
# The following is a workaround. An alternative is to inline the variable:
# - https://www.mail-archive.com/libtool-patches%40gnu.org/msg07752.html
# - https://github.com/ddclient/ddclient/commit/a12398c315b9b909e57e87acf9fd3a15a0b3e213
for pkg in $packages; do
  sed -i 's/ -Werror//g' "$pkg/configure.ac"
done

# Regenerate configure/libtool files because the checked-in files have a bug
# fixed in libtool 2.5.4.
# See https://www.mail-archive.com/libtool-patches%40gnu.org/msg07524.html
autoreconf -fi
for pkg in $packages; do
  autoreconf -fi "$pkg"
done

sed -i 's|#define CXX \\"$CXX\\"|#define CXX \\"$prefix/bin/c++\\"|' basix/configure
grep -F '#define CXX \"$prefix/bin/c++\"' basix/configure

./configure --prefix="${PREFIX}" --enable-mmcomp --enable-mmxlight
make -j"${CPU_COUNT}"
make install
