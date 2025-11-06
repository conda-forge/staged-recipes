#!/bin/bash

export CMAKE_POLICY_VERSION_MINIMUM=4.0

mkdir build
cd build
cmake ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TEST=ON \
  ../iceoryx_meta

make -j${CPU_COUNT}
if [[ "$target_platform" != "linux-"* ]]; then
  # Linux fails https://github.com/elfenpiff/iceoryx/blob/e7f5dc5bfa4ef0ef27f197992d7e37e6c83f758c/doc/website/FAQ.md#iceoryx-crashes-with-sigabrt-when-reserving-shared-memory-in-a-docker-envirnonment
  make all_tests
fi
make install
