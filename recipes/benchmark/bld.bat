mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

cmake -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE=release ^
      -DBENCHMARK_ENABLE_TESTING:BOOL=OFF ^
      -DBENCHMARK_ENABLE_GTEST_TESTS:BOOL=OFF ^
      ..

cmake --build . --target INSTALL --config Release

popd
