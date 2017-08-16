mkdir "%SRC_DIR%"\cpp\build
pushd "%SRC_DIR%"\cpp\build

set ARROW_BUILD_TOOLCHAIN=%LIBRARY_PREFIX%

cmake -G "Visual Studio 14 2015 Win64" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DARROW_BOOST_USE_SHARED:BOOL=OFF ^
      -DARROW_BUILD_TESTS:BOOL=OFF ^
      -DARROW_BUILD_UTILITIES:BOOL=OFF ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DARROW_PYTHON=on ^
      ..

cmake --build . --target INSTALL --config Release

popd
