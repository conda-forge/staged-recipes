mkdir build
cd build 

cmake -G "Ninja" ^
      -D CMAKE_BUILD_TYPE:STRING="Release" ^
      -D CMAKE_PREFIX_PATH:FILEPATH="%PREFIX%" ^
      -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
      -D BUILD_PY_LIB:BOOL=ON ^
      -D USE_PY_3:BOOL=ON ^
      ../src

if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
