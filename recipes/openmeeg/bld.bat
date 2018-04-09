echo "cmake  %SRC_DIR% -D BLA_VENDOR=OpenBLAS -D ENABLE_PYTHON=ON -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_DOCUMENTATION=OFF -G \"NMake Makefiles\""
cmake  %SRC_DIR% ^
       -G "NMake Makefiles" ^
       -D BLA_VENDOR=OpenBLAS ^
       -D ENABLE_PYTHON=ON ^
       -D CMAKE_BUILD_TYPE=RELEASE ^
       -D BUILD_DOCUMENTATION=OFF ^



if errorlevel 1 exit rem 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
