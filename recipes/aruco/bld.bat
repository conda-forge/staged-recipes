@echo ON
setlocal enabledelayedexpansion

mkdir build
cd build
cmake -LAH                                                                          ^
    -DCMAKE_BUILD_TYPE="Release"                                                    ^
    -DCMAKE_PREFIX_PATH=${PREFIX}                                                   ^
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                                ^
    ..
if errorlevel 1 exit 1
cmake --build . --target install --config Release