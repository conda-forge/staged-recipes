cd karilang-kernel

cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D YY_NO_UNISTD_H=1 ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DXEXTRA_JUPYTER_DATA_DIR=%PREFIX%\\share\\jupyter ^
      %SRC_DIR%\\karilang-kernel
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
