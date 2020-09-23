REM Install library with zfp-config.cmake files with cmake

mkdir build
cd build

cmake ^
    -G "NMake Makefiles"        ^
    -DCMAKE_BUILD_TYPE=Release  ^
    -DBUILD_SHARED_LIBS=ON      ^
    -DCMAKE_INSTALL_LIBDIR=lib  ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
    %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake test
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
