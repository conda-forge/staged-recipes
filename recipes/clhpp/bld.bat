copy "%RECIPE_DIR%\LICENSE.txt" "%SRC_DIR%\LICENSE.txt"

mkdir build_release
cd build_release

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_INC%" ^
    -DBUILD_DOCS=OFF ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTS=OFF ^
    -DOPENCL_DIST_DIR="%LIBRARY_PREFIX%" ^
    "%SRC_DIR%"
nmake
nmake install
