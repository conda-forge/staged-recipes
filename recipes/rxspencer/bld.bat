cmake -S%SRC_DIR% -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -Drxshared=1
if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --build build -- test
if errorlevel 1 exit 1

cmake --build build -- install
if errorlevel 1 exit 1
