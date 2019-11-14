mkdir build && cd build

cmake -G "NMake Makefiles" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH="%PREFIX%" ^
      -DCMAKE_INCLUDE_PATH="%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      -DBUILD_SHARED_LIBS:BOOL=ON ^
      -DBUILD_STATIC_LIBS=OFF ^
      %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
