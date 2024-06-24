#!/bin/sh

# librt is needed for sem_* symbols
if [[ "${target_platform}" == linux-* ]] ; then
    export LDFLAGS="-lrt ${LDFLAGS}"
fi

mkdir build && cd build

cmake -GNinja ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DZENOHC_INSTALL_STATIC_LIBRARY:BOOL=OFF \
      -DZENOHC_LIB_STATIC:BOOL=OFF \
      -DZENOHC_CARGO_FLAGS:STRING="--locked" \
      -DBUILD_TESTING:BOOL=ON \
      $SRC_DIR

cmake --build .
cmake --install .

cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml

cmake --build . --target tests --config Release
ctest -C Release --output-on-failure -E "(unit_z_api_alignment_test|build_z_build_static)"
