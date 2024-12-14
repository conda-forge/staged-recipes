#!/bin/bash

set -e

mkdir -p $PREFIX/lib/cmake/nvshmem/

cp -rv bin $PREFIX/
cp -rv include/ $PREFIX/
cp -rv lib/cmake/ $PREFIX/lib/
cp -rv lib/libnvshmem_host.so $PREFIX/lib
cp -rv lib/nvshmem_bootstrap*.so $PREFIX/lib
cp -rv lib/nvshmem_transport*.so $PREFIX/lib
cp -rv share/ $PREFIX/

