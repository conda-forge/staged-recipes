mkdir build
cd build

::Configure
meson --prefix=%LIBRARY_PREFIX% --buildtype=release -Dtests=false %SRC_DIR% 
if errorlevel 1 exit 1

:: Install.
ninja install
if errorlevel 1 exit 1
