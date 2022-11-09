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
    -D WITH_LIBPNGINC:PATH=%LIBRARY_PREFIX% ^
    -D WITH_LIBTIFFINC:PATH=%LIBRARY_PREFIX% ^
    -D WITH_LIBXMLINC:PATH=%LIBRARY_PREFIX% ^
    -D WITH_OPENSSLINC:PATH=%LIBRARY_PREFIX% ^
    -D WITH_ZLIBINC:PATH=%LIBRARY_PREFIX% ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release --target install --parallel
if errorlevel 1 exit 1
