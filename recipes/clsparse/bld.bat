mkdir build_release
cd build_release

if "%ARCH%" == "64" (
    set clSPARSE_BUILD64=ON
) else (
    set clSPARSE_BUILD64=OFF
)

set CL=%CL% /I"%LIBRARY_INC%"

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%LIBRARY_LIB%" ^
    -DclSPARSE_BUILD64="%clSPARSE_BUILD64%" ^
    -DUSE_SYSTEM_CL2HPP=1 ^
    -DSUFFIX_BIN="" ^
    -DSUFFIX_LIB="" ^
    -DBUILD_TESTS=OFF ^
    -DOPENCL_ROOT="%LIBRARY_PREFIX%" ^
    "%SRC_DIR%\src"
nmake
nmake install
