@echo ON
setlocal enabledelayedexpansion

mkdir build
cd build

cmake -LAH -G "Ninja"                                                     ^
    -DCMAKE_BUILD_TYPE="Release"                                          ^
    -DCMAKE_INSTALL_PREFIX=%UNIX_LIBRARY_PREFIX%                          ^
    -DCMAKE_PREFIX_PATH=%UNIX_LIBRARY_PREFIX%                             ^
    -DOPENCV_BIN_INSTALL_PATH=bin                                         ^
    -DOPENCV_LIB_INSTALL_PATH=lib                                         ^
    -DBUILD_SHARED_LIBS=1                                                 ^
    ..

if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

