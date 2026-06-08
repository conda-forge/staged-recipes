#!/bin/bash
set -ex

# The release tarball ships without .git/ or a .release_version file, so
# m4/get_version.sh (invoked by autogen.sh) can't derive a version on its
# own; provide it explicitly.
echo "${PKG_VERSION}" > .release_version

./autogen.sh

./configure \
    --prefix=${PREFIX} \
    --with-libfabric=${PREFIX} \
    --with-hwloc=${PREFIX} \
    --with-cuda=${PREFIX}

make -j"$(nproc)"
make install
make -C tests/unit check
