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
    -DpyAMReX_amrex_internal=OFF    ^
    -DpyAMReX_pybind11_internal=OFF ^
    -DPython_EXECUTABLE=%PYTHON%    ^
    -DPYINSTALLOPTIONS="--no-build-isolation"
if errorlevel 1 exit 1

:: build, pack & install
cmake --build build --config Release --parallel %CPU_COUNT% --target pip_install_nodeps
if errorlevel 1 exit 1
