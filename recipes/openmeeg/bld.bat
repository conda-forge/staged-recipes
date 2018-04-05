cmake  %SRC_DIR% -D BLA_VENDOR=OpenBLASS -D ENABLE_PYTHON=ON -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_DOCUMENTATION=OFF -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -G "NMake Makefiles"
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
