#!/bin/bash

set -ex

./autogen.sh

args=(
  --prefix="$PREFIX"
  --disable-doc
  --disable-debug
  --disable-prelude # conda-forge does not have libprelude yet
  --enable-isadir="$PREFIX/lib/security"
  --disable-econf # conda-forge does not have libeconf yet?
  --enable-openssl
  --disable-regenerate-docu
)

./configure "${args[@]}"

make

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

rm -f "$PREFIX/etc/pam.d/other"

make install
