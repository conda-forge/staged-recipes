@echo on

mkdir build
cd build

cmake ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    ..\src ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_BUILD_TYPE=Release ^
    -G "NMake Makefiles" ^
    %CMAKE_ARGS%

cmake --build . --config Release

cmake --build . --target test --config Release

cmake --build . --target install --config Release
