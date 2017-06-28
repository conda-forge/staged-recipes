mkdir build_release
cd build_release

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%LIBRARY_LIB%" ^
    -DSUFFIX_BIN="" ^
    -DSUFFIX_LIB="" ^
    -DBUILD_TEST=OFF ^
    -DBUILD_KTEST=OFF ^
    -DBUILD_CLIENT=OFF ^
    -DBUILD_CALLBACK_CLIENT=OFF ^
    -DBUILD_EXAMPLES=OFF ^
    -DOPENCL_ROOT="%LIBRARY_PREFIX%" ^
    "%SRC_DIR%\src"
nmake
nmake install
