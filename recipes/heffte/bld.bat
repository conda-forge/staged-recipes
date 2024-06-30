@echo on

:: configure
cmake ^
    -S %SRC_DIR% -B build           ^
    %CMAKE_ARGS%                    ^
    -G "Ninja"                      ^
    -DBUILD_SHARED_LIBS=ON          ^
    -DCMAKE_BUILD_TYPE=Release      ^
    -DCMAKE_C_COMPILER=clang-cl     ^
    -DCMAKE_CXX_COMPILER=clang-cl   ^
    -DCMAKE_INSTALL_LIBDIR=lib      ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_LINKER=lld-link         ^
    -DCMAKE_NM=llvm-nm              ^
    -DCMAKE_VERBOSE_MAKEFILE=ON     ^
    -DHeffte_DISABLE_GPU_AWARE_MPI=ON ^
    -DHeffte_ENABLE_AVX=ON            ^
    -DHeffte_ENABLE_AVX512=OFF        ^
    -DHeffte_ENABLE_FFTW=ON           ^
    -DHeffte_ENABLE_CUDA=OFF          ^
    -DHeffte_ENABLE_ROCM=OFF          ^
    -DHeffte_ENABLE_ONEAPI=OFF        ^
    -DHeffte_ENABLE_MKL=OFF           ^
    -DHeffte_ENABLE_DOXYGEN=OFF       ^
    -DHeffte_SEQUENTIAL_TESTING=ON    ^
    -DHeffte_ENABLE_TESTING=ON        ^
    -DHeffte_ENABLE_TRACING=OFF       ^
    -DHeffte_ENABLE_PYTHON=OFF        ^
    -DHeffte_ENABLE_FORTRAN=OFF       ^
    -DHeffte_ENABLE_SWIG=OFF          ^
    -DHeffte_ENABLE_MAGMA=OFF
if errorlevel 1 exit 1

:: build, pack & install
cmake --build build --config Release --parallel %CPU_COUNT% --target install
if errorlevel 1 exit 1
