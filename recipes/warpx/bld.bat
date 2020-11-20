echo "CFLAGS: %CFLAGS%"
echo "CXXFLAGS: %CXXFLAGS%"
echo "LDFLAGS: %LDFLAGS%"

:: set CC=clang-cl.exe
:: set CXX=clang-cl.exe

cmake ^
    -S . -B build                         ^
    -T "ClangCl"                          ^
    -DCMAKE_BUILD_TYPE=RelWithDebInfo     ^
    -DWarpX_amrex_branch=%PKG_VERSION%    ^
    -DWarpX_openpmd_internal=OFF          ^
    -DWarpX_openpmd_branch=0.12.0-alpha   ^
    -DWarpX_picsar_branch=d60c72ff5aa15dbd7e225654964b6c4fb10d52e2 ^
    -DWarpX_ASCENT=OFF  ^
    -DWarpX_MPI=OFF     ^
    -DWarpX_OPENPMD=ON  ^
    -DWarpX_PSATD=OFF   ^
    -DWarpX_QED=ON      ^
    -DWarpX_DIMS=3      ^
    %SRC_DIR%
if errorlevel 1 exit 1

cmake --build build --config RelWithDebInfo --parallel 2
if errorlevel 1 exit 1

:: future: test

:: future: install
mkdir %LIBRARY_PREFIX%\bin
cp bin\warpx*.exe %LIBRARY_PREFIX%\bin\

