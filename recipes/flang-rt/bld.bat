@echo on

mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ^
    -DCMAKE_Fortran_COMPILER=%BUILD_PREFIX%/Library/bin/flang.exe ^
    -DCMAKE_Fortran_COMPILER_WORKS=yes ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_MODULE_PATH=../cmake/Modules ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%;%LIBRARY_LIB%/clang/%PKG_VERSION% ^
    -DLLVM_EXTERNAL_LIT=%LIBRARY_BIN%/lit ^
    -DLLVM_LIT_ARGS=-v ^
    -DLLVM_CMAKE_DIR=%LIBRARY_LIB%/cmake/llvm ^
    -DLLVM_DIR=%LIBRARY_LIB%/cmake/llvm ^
    -DLLVM_ENABLE_RUNTIMES="flang-rt" ^
    -DFLANG_RT_INCLUDE_TESTS=OFF ^
    ..\runtimes
if %ERRORLEVEL% neq 0 exit 1

cmake --build . -j2
if %ERRORLEVEL% neq 0 exit 1

cmake --install .
if %ERRORLEVEL% neq 0 exit 1

del /s /q %LIBRARY_PREFIX%\compile_commands.json
