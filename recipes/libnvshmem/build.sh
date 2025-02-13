#!/bin/bash

set -e

$BUILD_PREFIX/bin/check-glibc bin/* lib/* bin/examples/* bin/perftest/device/coll/* bin/perftest/device/pt-to-pt/* bin/perftest/host/coll/* bin/perftest/host/init/* bin/perftest/host/pt-to-pt/*

mkdir -p $PREFIX/lib/

cp -rv bin $PREFIX/
cp -rv include $PREFIX/
cp -rv lib/cmake $PREFIX/lib/
cp -rv lib/*nvshmem*.so* $PREFIX/lib
cp -rv lib/*nvshmem*.a $PREFIX/lib
cp -rv share/ $PREFIX/

