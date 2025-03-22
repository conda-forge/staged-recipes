:: Borrowed from LibTurboJpeg
:: Build step
mkdir build
cd  build

cmake -G "NMake Makefiles" ^
    -D CMAKE_INSTALL_PREFIX=$PREFIX ^
    -D CMAKE_INSTALL_LIBDIR=$PREFIX/lib ^
    -D IRIS_BUILD_SHARED=OFF ^
    -D IRIS_BUILD_STATIC=OFF ^
    -D IRIS_BUILD_ENCODER=ON ^
    -D IRIS_BUILD_DEPENDENCIES=OFF ^
    -D IRIS_BUILD_PYTHON=ON ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_ASM_NASM_COMPILER=yasm ^
    $SRC_DIR
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

:: Install step
nmake install
if errorlevel 1 exit 1