:: build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DBLAS_LIBRARIES="%LIBRARY_LIB%\openblas.lib" ^
    -DLAPACK_LIBRARIES="%LIBRARY_LIB%\openblas.lib" ^
    -DBUILD_SHARED_LIBS=ON ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"
