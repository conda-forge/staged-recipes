mkdir build_cpp
cd build_cpp

cmake %SRC_DIR% -G "%CMAKE_GENERATOR%" ^
                -DVERSION_TAG="%PKG_VERSION%" ^
                -DCMAKE_PREFIX_PATH="%PREFIX%" ^
                -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
                -DBUILD_TESTS=OFF
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
