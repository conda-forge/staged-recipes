REM Don't use vendored happly (git submodule)
rmdir /s /q deps\happly
mkdir deps\happly

copy %PREFIX%\include\happly.h deps\happly\happly.h

mkdir build
cd build
cmake ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    ..

cmake --build . -j %NUMBER_OF_PROCESSORS%
cmake --build . --target install