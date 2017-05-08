mkdir build
cd build
cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DITK_DIR=%LIBRARY_PREFIX%/lib/cmake/ITK-4.11/ ^
	..

cmake --build . --config Release

cmake --build . --config Release --target install
