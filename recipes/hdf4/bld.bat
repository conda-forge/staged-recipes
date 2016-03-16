mkdir build
cd build

REM Configure step
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release ^
-DHDF4_BUILD_HL_LIB=ON ^
-DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
-DZLIB_LIBRARY=%LIBRARY_LIB%\zlibstatic.lib ^
-DZLIB_INCLUDE_DIR=%LIBRARY_INC% ^
-DJPEG_LIBRARY=%LIBRARY_LIB%\jpeg.lib ^
-DJPEG_INCLUDE_DIR=%LIBRARY_INC% ^
-DHDF4_BUILD_FORTRAN=NO ^
-DHDF4_ENABLE_NETCDF=NO ^
-DBUILD_SHARED_LIBS:BOOL=ON ^
-DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% %SRC_DIR%

if errorlevel 1 exit 1

REM Build step
nmake
if errorlevel 1 exit 1

REM Install step
nmake install
if errorlevel 1 exit 1
