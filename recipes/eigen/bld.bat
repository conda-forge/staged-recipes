mkdir build
cd build

set CMAKE_CONFIG="Release"

if "%PY_VER%" == "3.4" (
    set GENERATOR=Visual Studio 10 2010
) else (
    if "%PY_VER%" == "3.5" (
        set GENERATOR=Visual Studio 14 2015
    ) else (
        set GENERATOR=Visual Studio 9 2008
    )
)

if %ARCH% EQU 64 (
    set GENERATOR=%GENERATOR% Win64
)

cmake .. -G"%GENERATOR%"             ^
 -DCMAKE_BUILD_TYPE=%CMAKE_CONFIG%   ^
 -DINCLUDE_INSTALL_DIR=%LIBRARY_INC% ^
 -DLIB_INSTALL_DIR=%LIBRARY_LIB%     ^
 -DBIN_INSTALL_DIR=%LIBRARY_BIN%

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL
