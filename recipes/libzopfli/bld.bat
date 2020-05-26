@echo ON
setlocal enabledelayedexpansion

mkdir build
cd build

REM Debian seems to put the include headers in its own zopfli directory

cmake -LAH -G "Ninja"                                                     ^
    -DCMAKE_BUILD_TYPE="Release"                                          ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%                               ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%                                  ^
    -DCMAKE_INSTALL_INCLUDEDIR=%LIBRARY_INC%\zopfli                       ^
    -DBUILD_SHARED_LIBS=1                                                 ^
    -DZOPFLI_BUILD_SHARED=1                                               ^
    ..

if errorlevel 1 exit 1

REM ninja install doesn't seem to create the .lib files
REM ninja install
ninja install
if errorlevel 1 exit 1
