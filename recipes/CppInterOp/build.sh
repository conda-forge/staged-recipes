#!/bin/bash

set -x

# Common settings

export CPU_COUNT="$(nproc --all)"
export backend=$(echo "${backend}" | tr '[:upper:]' '[:lower:]')
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${BUILD_PREFIX}/x86_64-conda-linux-gnu/lib:${BUILD_PREFIX}/lib:${PREFIX}/lib"
#export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:$PWD/include:${BUILD_PREFIX}/x86_64-conda-linux-gnu/include/c++/12.3.0:${BUILD_PREFIX}/x86_64-conda-linux-gnu/include/c++/12.3.0/x86_64-conda-linux-gnu:${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include:${BUILD_PREFIX}/include:${PREFIX}/include"
sys_include_path=$(LC_ALL=C x86_64-conda-linux-gnu-g++ -O3 -DNDEBUG -xc++ -E -v /dev/null 2>&1 | sed -n -e '/^.include/,${' -e '/^ \/.*++/p' -e '}' | xargs -I$ echo "$" | tr '\n' ':')
export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:$PWD/include:$sys_include_path:${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include:${BUILD_PREFIX}/include:${PREFIX}/include"
export CMAKE_EXTRA_CLANG_PARAMS=""
export DO_BUILD_CLANG="0"

export clangdev_tag=${clangdev/\.\*/}
clangdev1=${clangdev_tag}.0.0
export clangdev_ver=${clangdev1/17\.0\.0/17.0.4}  # fix: clang 17.0.0 is removed from releases

# LLVM/Clang settings

export LLVM_DIR="${SRC_DIR}/llvm_project"
export LLVM_BUILD_DIR="${LLVM_DIR}/build"

if [[ "${backend}" == "repl" ]]; then
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${LLVM_BUILD_DIR}/lib:${LLVM_DIR}/lib"
  #export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:${LLVM_BUILD_DIR}/tools/clang/include:${LLVM_BUILD_DIR}/include:${LLVM_DIR}/clang/include:${LLVM_DIR}/llvm/include"

  x=$(conda list -q --json "^clang$")
  if [[ "$x" == "[]" ]]; then #conda package not installed
    wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-$clangdev_ver.tar.gz
    mkdir llvm-project
    tar --strip-components=1 -xf llvmorg-$clangdev_ver.tar.gz -C llvm-project

    export DO_BUILD_CLANG="1"
    export CMAKE_BUILD_CLANG_TARGETS="clang-repl"
  fi
fi

### Cling settings

if [[ "${backend}" == "cling" ]]; then
  export CLING_DIR="${SRC_DIR}/cling"
  export CLING_BUILD_DIR="${LLVM_BUILD_DIR}"
  #export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:${CLING_BUILD_DIR}/include:${CLING_DIR}/tools/cling/include"
  export CMAKE_EXTRA_CLANG_PARAMS="-DLLVM_EXTERNAL_PROJECTS=cling -DLLVM_EXTERNAL_CLING_SOURCE_DIR=${CLING_DIR}"

  aname="cling-llvm${clangdev_tag}.tar.gz"
  wget https://github.com/root-project/llvm-project/archive/refs/heads/$aname
  mkdir llvm-project
  tar --strip-components=1 -xf ${aname} -C llvm-project
  rm -f $aname

  aname=${clingdev_tag}.tar.gz
  wget https://github.com/root-project/cling/archive/$aname
  mkdir cling
  tar --strip-components=1 -xf $aname -C cling
  rm -f $aname

  export DO_BUILD_CLANG="1"
  export CMAKE_BUILD_CLANG_TARGETS="cling"
fi

### LLVM/Clang (with optional Cling) build

if [[ "$DO_BUILD_CLANG" == "1" ]]; then
  pushd llvm-project

  # apply patches on LLVM/Clang
  echo "Apply clang$clangdev_tag-*.patch patches from cppinterop:"
  compgen -G "../cppinterop/patches/llvm/clang$clangdev_tag-*.patch" > /dev/null && find ../cppinterop/patches/llvm/clang$clangdev_tag-*.patch -exec basename {} \; && patch --no-backup-if-mismatch -p1 -u -s -t -i ../cppinterop/patches/llvm/clang$clangdev_tag-*.patch
  echo "Apply clang$clangdev_tag-*.patch patches from package:"
  compgen -G "../add_patches/llvm/clang$clangdev_tag-*.patch" > /dev/null && find ../add_patches/llvm/clang$clangdev_tag-*.patch  -exec basename {} \;  && patch --no-backup-if-mismatch -p1 -u -s -t -i ../add_patches/llvm/clang$clangdev_tag-*.patch

  # apply patches on Cling
  pushd ../cling
  echo "Apply cling$clingdev_tag-*.patch patches from package:"
  compgen -G "../add_patches/cling/cling-*.patch" > /dev/null && find ../add_patches/cling/cling-*.patch  -exec basename {} \;  && patch --no-backup-if-mismatch -p1 -u -s -t -i ../add_patches/cling/cling-*.patch
  popd

  # cmake & build
  mkdir build
  cd build
  cmake \
      ${CMAKE_ARGS}                                 \
      -DLLVM_DEFAULT_TARGET_TRIPLE=${CONDA_TOOLCHAIN_HOST} \
      -DLLVM_HOST_TRIPLE=${CONDA_TOOLCHAIN_HOST}    \
      -DLLVM_UTILS_INSTALL_DIR=libexec/llvm         \
      -DLLVM_ENABLE_PROJECTS="clang"                \
      -DLLVM_ENABLE_ASSERTIONS=ON                   \
      -DCLANG_ENABLE_STATIC_ANALYZER=OFF            \
      -DCLANG_ENABLE_ARCMT=OFF                      \
      -DCLANG_ENABLE_BOOTSTRAP=OFF                  \
      -DLLVM_ENABLE_TERMINFO=OFF                    \
      -DCLANG_INCLUDE_TESTS=OFF                     \
      -DCLANG_INCLUDE_DOCS=OFF                      \
      -DLLVM_INCLUDE_TESTS=OFF                      \
      -DLLVM_INCLUDE_DOCS=OFF                       \
      ${CMAKE_EXTRA_CLANG_PARAMS}                         \
      ../llvm
  cmake --build . --target ${CMAKE_BUILD_CLANG_TARGETS} --parallel ${CPU_COUNT}
#  make install ${CMAKE_BUILD_CLANG_TARGETS}

  popd # llvm-project/
fi

### Build CppInterOp next to cling and llvm-project.

pushd cppinterop
mkdir build
cd build

export CPPINTEROP_BUILD_DIR=$PWD
CMAKE_EXTRA_CLING_PARAMS=""
if [[ "$DO_BUILD_CLANG" == "1" ]]; then
  # For some reason the folders are expanded to $SRC_DIR/llvm-project/...
  # and we cannot use the LLVM_BUILD_DIR and other variables.
  CMAKE_EXTRA_CLING_PARAMS="-DCling_DIR=${SRC_DIR}/llvm-project/build/tools/cling -DLLVM_DIR=${SRC_DIR}/llvm-project/build"
fi

if [[ "${backend}" == "cling" ]]; then
  cmake \
    ${CMAKE_ARGS}                     \
    -DUSE_CLING=ON                    \
    -DUSE_REPL=OFF                    \
    -DBUILD_SHARED_LIBS=ON            \
    -DCPPINTEROP_ENABLE_TESTING=OFF   \
    ${CMAKE_EXTRA_CLING_PARAMS}       \
    ..
else
  cmake \
    ${CMAKE_ARGS}                     \
    -DUSE_CLING=OFF                   \
    -DUSE_REPL=ON                     \
    -DBUILD_SHARED_LIBS=ON            \
    -DCPPINTEROP_ENABLE_TESTING=ON    \
    ${CMAKE_EXTRA_CLING_PARAMS}       \
    ..
fi

cmake --build . --parallel ${CPU_COUNT}
# FIXME: There is one failing tests in Release mode. Investigate.
cmake --build . --target check-cppinterop --parallel ${CPU_COUNT} || true

make install

popd
