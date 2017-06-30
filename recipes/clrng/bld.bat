mkdir build_release
cd build_release

if "%ARCH%" == "64" (
    set BUILD64=ON
) else (
    set BUILD64=OFF
)

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%LIBRARY_LIB%" ^
    -DBUILD64="%BUILD64%" ^
    -DSUFFIX_BIN="" ^
    -DSUFFIX_LIB="" ^
    -DBUILD_TEST=OFF ^
    -DBUILD_CLIENT=OFF ^
    -DOPENCL_ROOT="%LIBRARY_PREFIX%" ^
    "%SRC_DIR%\src"
nmake
nmake install
