set CC=clang-cl.exe
set CXX=clang-cl.exe

:: work-around for M_PI usage in code
set "CXXFLAGS=%CXXFLAGS% /D_USE_MATH_DEFINES"

:: -T "ClangCl"

cmake ^
    -S . -B build                         ^
    -DCMAKE_BUILD_TYPE=RelWithDebInfo     ^
    -DWarpX_amrex_branch=%PKG_VERSION%    ^
    -DWarpX_openpmd_internal=OFF          ^
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
cp build\bin\warpx*.exe %LIBRARY_PREFIX%\bin\

