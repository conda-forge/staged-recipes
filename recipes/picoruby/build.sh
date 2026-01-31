#!/bin/bash

set -exo pipefail

export LD=${CC}
export MRUBY_CONFIG="${SRC_DIR}/build_config/default.rb"

rake

mkdir -p ${PREFIX}/{bin,include,lib}
install -m 755 bin/* ${PREFIX}/bin
install -m 644 build/host/lib/*.a ${PREFIX}/lib
test -d "include" && cp -r include/* "${PREFIX}/include/" || true
