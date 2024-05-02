#!/usr/bin/env bash

set -euxo pipefail

if [[ $PKG_NAME == "libfinufft" ]]; then

    cmake                                     \
        -B build-lib                          \
        -G Ninja                              \
        ${CMAKE_ARGS}                         \
        -DCMAKE_BUILD_TYPE=Release            \
        -DCMAKE_INSTALL_LIBDIR=lib            \
        -DCMAKE_INSTALL_PREFIX=${PREFIX}      \
        -DFINUFFT_USE_OPENMP=ON
    cmake --build build-lib --parallel ${CPU_COUNT}
    cmake --install build-lib
    rm -rf ${PREFIX}/lib/libfinufft_static.a

elif [[ $PKG_NAME == "libcufinufft" ]]; then

    cmake                                     \
        -B build-lib                          \
        -G Ninja                              \
        ${CMAKE_ARGS}                         \
        -DCMAKE_BUILD_TYPE=Release            \
        -DCMAKE_INSTALL_LIBDIR=lib            \
        -DCMAKE_INSTALL_PREFIX=${PREFIX}      \
        -DFINUFFT_USE_OPENMP=ON               \
        -DFINUFFT_USE_CUDA=ON                 \
        -DCMAKE_CUDA_ARCHITECTURES=all
    cmake --build build-lib --parallel ${CPU_COUNT} --target cufinufft

    # Install manually because CMake can't just install one target
    cp include/cufinufft.h ${PREFIX}/include/cufinufft.h
    cp include/cufinufft_opts.h ${PREFIX}/include/cufinufft_opts.h
    cp include/finufft_errors.h ${PREFIX}/include/finufft_errors.h
    cp build-lib/libcufinufft${SHLIB_EXT} ${PREFIX}/lib/libcufinufft${SHLIB_EXT}

elif [[ $PKG_NAME == "finufft" ]]; then

    "${PYTHON}" -m pip install --no-deps --no-build-isolation -vv ./python/finufft

elif [[ $PKG_NAME == "cufinufft" ]]; then

    export CUFINUFFT_DIR="${PREFIX}/lib/"
    "${PYTHON}" -m pip install --no-deps --no-build-isolation -vv ./python/cufinufft

fi
