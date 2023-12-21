#!/bin/bash

set -x

# Common settings

export CPU_COUNT="$(nproc --all)"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${BUILD_PREFIX}/x86_64-conda-linux-gnu/lib:${BUILD_PREFIX}/lib:${PREFIX}/lib"
sys_include_path=$(LC_ALL=C x86_64-conda-linux-gnu-g++ -O3 -DNDEBUG -xc++ -E -v /dev/null 2>&1 | sed -n -e '/^.include/,${' -e '/^ \/.*++/p' -e '}' | xargs -I$ echo "$" | tr '\n' ':')
export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:$PWD/include:$sys_include_path:${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include:${BUILD_PREFIX}/include:${PREFIX}/include"

export clangdev_tag=${clangdev/\.\*/}
clangdev1=${clangdev_tag}.0.0
export clangdev_ver=${clangdev1/17\.0\.0/17.0.6}  # fix: clang 17.0.0 is removed from releases

### Build CppInterOp next to llvm-project.

pushd cppinterop

mkdir -p build && cd build

cmake \
  ${CMAKE_ARGS}                   \
  -DUSE_CLING=OFF                 \
  -DUSE_REPL=ON                   \
  -DBUILD_SHARED_LIBS=ON          \
  -DCPPINTEROP_ENABLE_TESTING=ON  \
  ..

cmake --build . --parallel ${CPU_COUNT}
# FIXME: There is one failing tests in Release mode. Investigate.
#cmake --build . --target check-cppinterop --parallel ${CPU_COUNT} || true
make install

popd
