#!/bin/bash
set -euxo pipefail

cd contrib/pzstd

# Upstream's pzstd target always rebuilds lib/libzstd.a from this source tree, so
# only compile pzstd's own objects and link the libzstd.a provided by zstd-static.
objects=(main.o Options.o Pzstd.o SkippableFrame.o ../../programs/util.o)
make -j"${CPU_COUNT}" "${objects[@]}" EXTRA_FLAGS=-DNDEBUG
${CXX} "${objects[@]}" "${PREFIX}/lib/libzstd.a" ${CXXFLAGS} ${LDFLAGS} -pthread -o pzstd

install -d "${PREFIX}/bin"
install -m 755 pzstd "${PREFIX}/bin/pzstd"
