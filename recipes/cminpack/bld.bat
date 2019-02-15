mkdir build
cd build

cmake -G "Ninja" ^
  -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
  -DBUILD_SHARED_LIBS:BOOL=ON ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
  -DUSE_BLAS:BOOL=OFF ^
  .. || goto :eof

ninja || goto :eof
ninja install || goto :eof

unix2dos ../examples/ref/*.ref
ctest --output-on-failure
