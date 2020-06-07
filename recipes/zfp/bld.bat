mkdir build
cd build

cmake -LAH -G "Ninja"  ^
    -DCMAKE_BUILD_TYPE="Release"               ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%       ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%    ^
    -DBUILD_ZFPY=ON                            ^
    -DBUILD_UTILITIES=ON                       ^
    -DBUILD_CFP=ON                             ^
    ..
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

copy bin\zfp.exe %LIBRARY_BIN%\.
if errorlevel 1 exit 1

exit 0
