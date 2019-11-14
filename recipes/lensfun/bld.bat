mkdir build && cd build

cmake -G "NMake Makefiles" ^
      -DGLIB2_BASE_DIR=glib-2.0
      -DBUILD_TESTS=off
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_INCLUDE_PATH="%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      -DBUILD_SHARED_LIBS:BOOL=ON ^
      %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
