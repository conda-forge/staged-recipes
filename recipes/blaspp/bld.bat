@echo on

cmake -S . -B build             ^
    -G "Ninja"                  ^
    -DCMAKE_INSTALL_BINDIR=bin               ^
    -DCMAKE_INSTALL_LIBDIR=lib               ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
    -DCMAKE_BUILD_TYPE=Release  ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -DBUILD_SHARED_LIBS=ON      ^
    -Dbuild_tests=OFF           ^
    -Duse_cmake_find_blas=ON    ^
    -Duse_openmp=OFF            ^
    -Duse_cuda=OFF
if errorlevel 1 exit 1

cmake --build build --config Release --parallel 2
if errorlevel 1 exit 1

cmake --build build --config Release --target install
if errorlevel 1 exit 1
