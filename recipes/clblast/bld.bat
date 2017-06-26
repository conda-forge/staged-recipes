mkdir build_release
cd build_release

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="%LIBRARY_BIN%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%LIBRARY_LIB%" ^
    -DOPENCL_ROOT="%LIBRARY_PREFIX%" ^
    "%SRC_DIR%"
nmake
nmake install
