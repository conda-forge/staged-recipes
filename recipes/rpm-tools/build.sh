#!/usr/bin/env bash

LUA_VERSION=$(lua -v | cut -f 2 -d ' ')
(sed -e "s@LUA_VERSION@${LUA_VERSION}@g" -e "s@CONDA_PREFIX@${PREFIX}@g" | \
 sed -E "s@^(V=.+)\.[0-9]+@\1@g" \
 > "lua.pc") << "EOF"
V=LUA_VERSION
R=LUA_VERSION

prefix=CONDA_PREFIX
INSTALL_BIN=${prefix}/bin
INSTALL_INC=${prefix}/include
INSTALL_LIB=${prefix}/lib
INSTALL_MAN=${prefix}/share/man/man1
INSTALL_LMOD=${prefix}/share/lua/${V}
INSTALL_CMOD=${prefix}/lib/lua/${V}
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: Lua
Description: An Extensible Extension Language
Version: ${R}
Requires:
Libs: -L${libdir} -llua -lm -ldl
Cflags: -I${includedir}
EOF
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:$PWD

./configure \
    --prefix="${PREFIX}"  \
    --enable-python \
    --with-external-db \
    --with-lua \
    --with-cap \
    PYTHON="${PYTHON}"

make "-j${CPU_COUNT}" install
make check
make installcheck

"${PYTHON}" -m pip install ./python -vv
