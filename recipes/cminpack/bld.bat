mkdir build
cd build

set CMAKE_BUILD_TYPE=RelWithDebInfo

cmake -G "Ninja" ^
  -DBUILD_SHARED_LIBS:BOOL=ON ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
  -DUSE_BLAS:BOOL=OFF ^
  .. || goto :eof

ninja || goto :eof
ninja install || goto :eof

unix2dos ../examples/ref/*.ref
ctest --output-on-failure
