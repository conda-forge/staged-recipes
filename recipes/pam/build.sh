#!/bin/bash
set -ex

./autogen.sh

args=(
  --prefix="$PREFIX"
  --disable-doc
  --disable-debug
  --disable-prelude
  --enable-isadir="$PREFIX/lib/security"
  --disable-econf
  --disable-openssl # check for pam_timestamp with openssl is broken
  --disable-regenerate-docu
)

./configure "${args[@]}"

make -j${CPU_COUNT}

mkdir -p "$PREFIX/etc/pam.d"
test ! -e "$PREFIX/etc/pam.d/other"

cat <<EOF > "$PREFIX/etc/pam.d/other" 
#%PAM-1.0
auth	 required	pam_deny.so
account	 required	pam_deny.so
password required	pam_deny.so
session	 required	pam_deny.so
EOF

make check

rm "$PREFIX/etc/pam.d/other"

make install
