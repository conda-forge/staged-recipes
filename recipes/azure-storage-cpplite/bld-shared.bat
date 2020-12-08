mkdir build-shared
cd build-shared
cmake .. -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D BUILD_SHARED_LIBS=ON
cmake --build . --config Release
