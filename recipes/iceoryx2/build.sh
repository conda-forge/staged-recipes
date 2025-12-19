#!/bin/bash

export LIBCLANG_PATH=$BUILD_PREFIX/lib
export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS} -C link-arg=-L${PREFIX}/lib"

cmake ${CMAKE_ARGS} -DRUST_TARGET_TRIPLET=${CARGO_BUILD_TARGET} .
make -j${CPU_COUNT}
make install
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

if [[ "${target_platform}" == "osx-"* ]]; then
  ${INSTALL_NAME_TOOL:-install_name_tool} -change ${SRC_DIR}/rust/${CARGO_BUILD_TARGET}/release/deps/libiceoryx2_ffi_c.dylib @rpath/libiceoryx2_ffi_c.dylib ${PREFIX}/lib/libiceoryx2_cxx.dylib
fi
