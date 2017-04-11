mkdir build_release
if errorlevel 1 exit 1

cd build_release
if errorlevel 1 exit 1

cmake -G "NMake Makefiles" ^
         -DCMAKE_BUILD_TYPE:STRING=RELEASE ^
         -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
         -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
         -DBUILD_SHARED_LIBS:BOOL=ON ^
         -DBUILD_STATIC_LIBS:BOOL=ON ^
         -DAPR_BUILD_TESTAPR:BOOL=ON ^
         %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake test
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
