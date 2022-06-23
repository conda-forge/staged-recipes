cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -B _build -G Ninja
if errorlevel 1 exit 1
cmake --build _build
if errorlevel 1 exit 1
cmake --install _build
if errorlevel 1 exit 1
