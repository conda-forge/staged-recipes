@echo on
setlocal EnableDelayedExpansion

:: Don't use vendored happly (git submodule)
rmdir /s /q deps\happly
mkdir deps\happly

copy %PREFIX%\include\happly.h deps\happly\happly.h

mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..

cmake --build . -j %CPU_COUNT%
cmake --build . --target install
