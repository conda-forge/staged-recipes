set -x

mkdir build
cd build

if [[ "$CC_FOR_BUILD" != "" && "$CC_FOR_BUILD" != "$CC" ]]; then
  NATIVE_FLAGS="-DCMAKE_C_COMPILER=$CC_FOR_BUILD;-DCMAKE_CXX_COMPILER=$CXX_FOR_BUILD;-DCMAKE_C_FLAGS=-O2;-DCMAKE_CXX_FLAGS=-O2"
  NATIVE_FLAGS="${NATIVE_FLAGS};-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath,${BUILD_PREFIX}/lib;-DCMAKE_MODULE_LINKER_FLAGS=;-DCMAKE_SHARED_LINKER_FLAGS="
  NATIVE_FLAGS="${NATIVE_FLAGS};-DCMAKE_STATIC_LINKER_FLAGS=;-DLLVM_INCLUDE_BENCHMARKS=OFF"
  NATIVE_FLAGS="${NATIVE_FLAGS};-DLLVM_ENABLE_ZSTD=OFF;-DLLVM_ENABLE_LIBXML2=OFF;-DLLVM_ENABLE_ZLIB=OFF;"
  CMAKE_ARGS="${CMAKE_ARGS} -DCROSS_TOOLCHAIN_FLAGS_NATIVE=${NATIVE_FLAGS}"
  CMAKE_ARGS="${CMAKE_ARGS} -DLLVM_HOST_TRIPLE=$(echo $HOST | sed s/conda/unknown/g) -DLLVM_DEFAULT_TARGET_TRIPLE=$(echo $HOST | sed s/conda/unknown/g)"
fi

# disable -fno-plt due to https://bugs.llvm.org/show_bug.cgi?id=51863 due to some GCC bug
if [[ "$target_platform" == "linux-ppc64le" ]]; then
  CFLAGS="$(echo $CFLAGS | sed 's/-fno-plt //g')"
  CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fno-plt //g')"
fi

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_LIBRARY_PATH="${PREFIX}" \
      -DLLVM_ENABLE_BACKTRACES=ON \
      -DLLVM_ENABLE_LIBEDIT=OFF \
      -DLLVM_ENABLE_LIBXML2=OFF \
      -DLLVM_ENABLE_RTTI=OFF \
      -DLLVM_ENABLE_TERMINFO=OFF \
      -DLLVM_ENABLE_ZLIB=FORCE_ON \
      -DLLVM_ENABLE_ZSTD=OFF \
      -DLLVM_INCLUDE_BENCHMARKS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_INCLUDE_GO_TESTS=OFF \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_UTILS=ON \
      -DLLVM_INSTALL_UTILS=ON \
      -DLLVM_UTILS_INSTALL_DIR=libexec/llvm \
      -DLLVM_BUILD_LLVM_DYLIB=no \
      -DLLVM_LINK_LLVM_DYLIB=no \
      -DLLVM_TARGETS_TO_BUILD=Metal \
      ${CMAKE_ARGS} \
      -GNinja \
      ../llvm

ninja -j${CPU_COUNT} tools/metallib-as/install tools/metallib-dis/install

mv ${PREFIX}/bin/metallib-as ${PREFIX}/bin/metallib-as-15
mv ${PREFIX}/bin/metallib-dis ${PREFIX}/bin/metallib-dis-15
