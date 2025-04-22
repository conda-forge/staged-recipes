#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pushd 3rd/luamake
compile/build.sh
popd
3rd/luamake/luamake rebuild

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/libexec/${PKG_NAME}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}/log
mkdir -p ${PREFIX}/bin

install -m 755 bin/lua-language-server ${PREFIX}/libexec/${PKG_NAME}/bin
install -m 755 bin/main.lua ${PREFIX}/libexec/${PKG_NAME}/bin
install -m 644 main.lua ${PREFIX}/libexec/${PKG_NAME}
install -m 644 debugger.lua ${PREFIX}/libexec/${PKG_NAME}
cp -r locale ${PREFIX}/libexec/${PKG_NAME}
cp -r meta ${PREFIX}/libexec/${PKG_NAME}
cp -r script ${PREFIX}/libexec/${PKG_NAME}
cp changelog.md ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/${PKG_NAME} <<EOF
#!/bin/sh
exec ${PREFIX}/libexec/${PKG_NAME}/bin/${PKG_NAME} "\$@"
EOF
