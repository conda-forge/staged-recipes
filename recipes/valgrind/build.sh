#!/bin/sh

set -e -o pipefail -x
./configure --prefix=${PREFIX}
chmod u+x ${SRC_DIR}/link_tool_exe_linux
chmod u+x ${SRC_DIR}/link_tool_exe_darwin
make
make install
make regtest

