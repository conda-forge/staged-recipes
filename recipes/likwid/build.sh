if [[ $CC == *"clang"* ]]; then
    export COMPILER="CLANG"
else
    export COMPILER="GCC"
fi

if [[ ${cuda_compiler_version} != "None" ]]; then
    CUDA_HOME=${PREFIX}/pkgs/cuda-toolkit make CC=${CC} CXX=${CXX} PREFIX=${PREFIX} NVIDIA_INTERFACE=true ACCESSMODE=perf_event COMPILER=$COMPILER -j${CPU_COUNT}
    CUDA_HOME=${PREFIX}/pkgs/cuda-toolkit make CC=${CC} CXX=${CXX} PREFIX=${PREFIX} NVIDIA_INTERFACE=true ACCESSMODE=perf_event COMPILER=$COMPILER install
else
    make CC=${CC} CXX=${CXX} PREFIX=${PREFIX} ACCESSMODE=perf_event COMPILER=$COMPILER -j${CPU_COUNT}
    make CC=${CC} CXX=${CXX} PREFIX=${PREFIX} ACCESSMODE=perf_event COMPILER=$COMPILER install
fi
