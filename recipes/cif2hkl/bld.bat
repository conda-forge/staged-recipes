@echo on

mkdir build || exit /b
cd build || exit /b

cmake ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    ..\src ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_BUILD_TYPE=Release ^
    -G "NMake Makefiles" ^
    %CMAKE_ARGS%  || exit /b

cmake --build . --config Release  || exit /b

cmake --build . --target test --config Release  || exit /b

cmake --build . --target install --config Release  || exit /b
