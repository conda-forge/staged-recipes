mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DOpenMP_RUNTIME_MSVC ^
    -DBUILD_SHARED_LIBS=OFF ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix %LIBRARY_PREFIX%
