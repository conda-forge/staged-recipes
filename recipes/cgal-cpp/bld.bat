mkdir build && cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"%CMAKE_GENERATOR%" ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DWITH_CGAL_ImageIO=OFF ^
  -DWITH_CGAL_Qt5=OFF ^
  .. || goto :eof

cmake --build . --config %CMAKE_CONFIG% --target INSTALL || goto :eof
ctest --output-on-failure
