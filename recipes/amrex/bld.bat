@echo on

:: configure
cmake ^
    -S %SRC_DIR% -B build           ^
    %CMAKE_ARGS%                    ^
    -G "Ninja"                      ^
    -DAMReX_ASCENT=OFF              ^
    -DAMReX_BUILD_TUTORIALS=OFF     ^
    -DAMReX_CONDUIT=OFF             ^
    -DAMReX_CUDA_LTO=OFF            ^
    -DAMReX_EB=OFF                  ^
    -DAMReX_ENABLE_TESTS=ON         ^
    -DAMReX_FORTRAN=OFF             ^
    -DAMReX_FORTRAN_INTERFACES=OFF  ^
    -DAMReX_GPU_BACKEND=NONE        ^
    -DAMReX_GPU_RDC=OFF             ^
    -DAMReX_HDF5=OFF                ^
    -DAMReX_HYPRE=OFF               ^
    -DAMReX_IPO=OFF                 ^
    -DAMReX_MPI=OFF                 ^
    -DAMReX_MPI_THREAD_MULTIPLE=OFF ^
    -DAMReX_OMP=ON                  ^
    -DAMReX_PARTICLES=ON            ^
    -DAMReX_PLOTFILE_TOOLS=OFF      ^
    -DAMReX_PROBINIT=OFF            ^
    -DAMReX_PIC=ON                  ^
    -DAMReX_SPACEDIM="1;2;3"        ^
    -DAMReX_SENSEI=OFF              ^
    -DAMReX_TEST_TYPE=Small         ^
    -DAMReX_TINY_PROFILE=ON         ^
    -DBUILD_SHARED_LIBS=ON          ^
    -DCMAKE_BUILD_TYPE=Release      ^
    -DCMAKE_C_COMPILER=clang-cl     ^
    -DCMAKE_CXX_COMPILER=clang-cl   ^
    -DCMAKE_INSTALL_LIBDIR=lib      ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_LINKER=lld-link         ^
    -DCMAKE_NM=llvm-nm              ^
    -DCMAKE_VERBOSE_MAKEFILE=ON
if errorlevel 1 exit 1

:: build
cmake --build build --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build build --config Release --target install
if errorlevel 1 exit 1

:: clean "symlink"
del "%LIBRARY_PREFIX%\lib\amrex.dll"
del "%LIBRARY_PREFIX%\bin\amrex.dll"

:: test
set "OMP_NUM_THREADS=2"
ctest --test-dir build --build-config Release --output-on-failure
if errorlevel 1 exit 1
