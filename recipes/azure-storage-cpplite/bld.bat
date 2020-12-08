mkdir build
cd build
cmake .. -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
cmake --build . --config Release
