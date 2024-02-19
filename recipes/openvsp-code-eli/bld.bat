cmake -G "NMake Makefiles" ^
  -D CMAKE_BUILD_TYPE=Release ^
  %CMAKE_ARGS% ^
  %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
