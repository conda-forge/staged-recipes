@echo on

mkdir build || exit /b 1
cd build || exit /b 1

cmake ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    ..\src ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_BUILD_TYPE=Release ^
    -G "NMake Makefiles" ^
    %CMAKE_ARGS%  || exit /b 1

cmake --build . --config Release  || exit /b 1

cmake --build . --target test --config Release  || exit /b 1

cmake --build . --target install --config Release  || exit /b 1

cd "%PREFIX%"  || exit /b 1
tree /F  || exit /b 1
