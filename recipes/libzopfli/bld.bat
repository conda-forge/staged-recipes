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
    -DOPENCV_BIN_INSTALL_PATH=bin                                         ^
    -DOPENCV_LIB_INSTALL_PATH=lib                                         ^
    -DBUILD_SHARED_LIBS=1                                                 ^
    -DZOPFLI_BUILD_SHARED=1                                               ^
    ..

if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

