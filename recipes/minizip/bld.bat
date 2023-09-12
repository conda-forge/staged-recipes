set CC=cl

cmake -S . -B . ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_LIBDIR="%LIBRARY_PREFIX%\lib" ^
  -DCMAKE_INSTALL_INCLUDEDIR="include\minizip" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=ON ^
  -DMZ_FORCE_FETCH_LIBS=OFF

cmake --build . --config Release

cmake --install . --config Release
