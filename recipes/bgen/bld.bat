mkdir build
cd build

cmake -G "NMake Makefiles" ^
         -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE ^
         -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX% ^
         %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake test
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
