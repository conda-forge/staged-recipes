cmake -GNinja                                  ^
      -D CMAKE_BUILD_TYPE=Release              ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      %SRC_DIR%
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
