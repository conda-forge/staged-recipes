mkdir build
cd build

REM See notes in build.sh
cmake ^
    -G Ninja ^
    -D CMAKE_BUILD_TYPE:STRING=Release ^
    -D BUILD_SHARED_LIBS:BOOL=TRUE ^
    -D CMAKE_INSTALL_PREFIX=%PREFIX% ^
    -D DCMTK_ENABLE_PRIVATE_TAGS:BOOL=TRUE ^
    -D DCMTK_WITH_ICONV:BOOL=OFF ^
    -D DCMTK_WITH_ICU:BOOL=OFF ^
    -D DCMTK_WITH_OPENJPEG:BOOL=OFF ^
    -D DCMTK_WITH_SNDFILE:BOOL=OFF ^
    -D DCMTK_USE_FIND_PACKAGE:BOOL=ON ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release --target install --parallel
if errorlevel 1 exit 1
