cmake -DBUILD_SHARED_LIBS=ON . 
cmake --build . --config=release
cmake --install . --config=release --prefix=%LIBRARY_PREFIX%
