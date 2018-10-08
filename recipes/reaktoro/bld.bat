mkdir build
cd build
cmake -G Ninja ^
      -DBUILD_ALL=ON ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INCLUDE_PATH="%LIBRARY_INC%" ^
      -DBOOST_INCLUDE_DIR="%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
      "-DTHIRDPARTY_COMMON_ARGS=-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON" ^
      ..
cmake --build . --config Release --target install
