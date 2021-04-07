mkdir _build
cd _build

set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig"

:: configure
cmake ^
    -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    "%SRC_DIR%"
if errorlevel 1 exit 1

:: build
cmake --build . --parallel "%CPU_COUNT%" --verbose
if errorlevel 1 exit 1

:: install
cmake --build . --parallel "%CPU_COUNT%" --verbose --target install
if errorlevel 1 exit 1
