#!/bin/bash

cd pytorch
set -ex
# Remove c10 subfolder to ensure we use conda-forge precompiled stuff
rm -rf c10
cuda_compiler_version=${cuda_compiler_version:-None}

# clean up an existing cmake build directory
rm -rf build

# uncomment to debug cmake build
# export CMAKE_VERBOSE_MAKEFILE=1

export CFLAGS="$(echo $CFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
export CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
export LDFLAGS="$(echo $LDFLAGS | sed 's/-Wl,--as-needed//g')"
export LDFLAGS="$(echo $LDFLAGS | sed 's/-Wl,-dead_strip_dylibs//g')"
export LDFLAGS_LD="$(echo $LDFLAGS_LD | sed 's/-dead_strip_dylibs//g')"
export CXXFLAGS="$CXXFLAGS -Wno-deprecated-declarations"
export CFLAGS="$CFLAGS -Wno-deprecated-declarations"

# Dynamic libraries need to be lazily loaded so that torch
# can be imported on system without a GPU
LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"

export CMAKE_GENERATOR=Ninja
export CMAKE_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include:$CMAKE_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$PREFIX
for ARG in $CMAKE_ARGS; do
  if [[ "$ARG" == "-DCMAKE_"* ]]; then
    cmake_arg=$(echo $ARG | cut -d= -f1)
    cmake_arg=$(echo $cmake_arg| cut -dD -f2-)
    cmake_val=$(echo $ARG | cut -d= -f2-)
    printf -v $cmake_arg "$cmake_val"
    export ${cmake_arg}
  fi
done
# unset CMAKE_INSTALL_PREFIX
# export TH_BINARY_BUILD=1
export PYTORCH_BUILD_VERSION=$PKG_VERSION
export PYTORCH_BUILD_NUMBER=$PKG_BUILDNUM

rm -rf $PREFIX/bin/protoc

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    export COMPILER_WORKS_EXITCODE=0
    export COMPILER_WORKS_EXITCODE__TRYRUN_OUTPUT=""
fi

export USE_MAGMA=0
export USE_NCCL=0
# MacOS build is simple, and will not be for CUDA
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Produce macOS builds with torch.distributed support.
    # This is enabled by default on Linux, but disabled by default on macOS,
    # because it requires an non-bundled compile-time dependency (libuv
    # through gloo). This dependency is made available through meta.yaml, so
    # we can override the default and set USE_DISTRIBUTED=1.
    export USE_DISTRIBUTED=1

    if [[ "$target_platform" == "osx-arm64" ]]; then
        export BLAS=OpenBLAS
        export USE_MKLDNN=0
        # There is a problem with pkg-config
        # See https://github.com/conda-forge/pkg-config-feedstock/issues/38
        export USE_DISTRIBUTED=0
    fi
fi

if [[ ${cuda_compiler_version} != "None" ]]; then
    export USE_CUDA=1
    export TORCH_CUDA_ARCH_LIST="3.5;5.0+PTX"
    if [[ ${cuda_compiler_version} == 9.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;7.0"
    elif [[ ${cuda_compiler_version} == 9.2* ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;6.1;7.0"
    elif [[ ${cuda_compiler_version} == 10.* ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;6.1;7.0;7.5"
    elif [[ ${cuda_compiler_version} == 11.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;6.1;7.0;7.5;8.0"
    elif [[ ${cuda_compiler_version} == 11.1 ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;6.1;7.0;7.5;8.0;8.6"
    elif [[ ${cuda_compiler_version} == 11.2 ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;6.1;7.0;7.5;8.0;8.6"
    else
        echo "unsupported cuda version. edit build_pytorch.sh"
        exit 1
    fi
    export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
    export NCCL_ROOT_DIR=$PREFIX
    export NCCL_INCLUDE_DIR=$PREFIX/include
    export USE_SYSTEM_NCCL=1
    export USE_STATIC_NCCL=0
    export USE_STATIC_CUDNN=0
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
    export MAGMA_HOME="${PREFIX}"
    export USE_MAGMA=1
    export USE_NCCL=1
    CMAKE_BLAS_ARG=
else
    if [[ "$target_platform" == *-64 ]]; then
      CMAKE_BLAS_ARG=-DBLAS=MKL
    else
      CMAKE_BLAS_ARG=
    fi
    export USE_CUDA=0
    export USE_MKLDNN=1
    export CMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake"
fi


mkdir build
cd build

# The CUDA binaries seem to be broken
cmake ${CMAKE_ARGS}                                \
    -DCMAKE_BUILD_TYPE=Release                     \
    -DCMAKE_GENERATOR=${CMAKE_GENERATOR}           \
    -DPYTHON_EXECUTABLE=${BUILD_PREFIX}/bin/python \
    -DCMAKE_LIBRARY_PATH="${CMAKE_LIBRARY_PATH}"   \
    -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}"     \
    -DINSTALL_TEST=0                               \
    -DBUILD_TEST=0                                 \
    -DUSE_SYSTEM_CPUINFO=1                         \
    -DUSE_SYSTEM_SLEEF=1                           \
    -DUSE_SYSTEM_GLOO=1                            \
    -DUSE_SYSTEM_FP16=1                            \
    -DUSE_SYSTEM_PYBIND11=1                        \
    -DUSE_SYSTEM_PTHREADPOOL=1                     \
    -DUSE_SYSTEM_PSIMD=1                           \
    -DUSE_SYSTEM_FXDIV=1                           \
    -DUSE_SYSTEM_ONNX=1                            \
    -DUSE_SYSTEM_XNNPACK=1                         \
    -DBUILD_CUSTOM_PROTOBUF=OFF                    \
    ${CMAKE_BLAS_ARG}                              \
    -DUSE_CUDA=${USE_CUDA}                         \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
    -DBUILD_PYTHON=OFF                             \
    -DBUILD_BINARY=OFF                             \
    -DHAVE_SOVERSION=ON                            \
    -DUSE_BREAKPAD=OFF                             \
    -DUSE_MAGMA=${USE_MAGMA}                       \
    -DUSE_MPI=OFF                                  \
    -DUSE_NUMA=OFF                                 \
    -DUSE_METAL=OFF                                \
    -DUSE_NCCL=${USE_MAGMA}                        \
    ..

ninja install -j${CPU_COUNT}
# Not sure how to get this to not get installed.
rm ${PREFIX}/lib/libpytorch_qnnpack.a
rm ${PREFIX}/include/qnnpack_func.h
