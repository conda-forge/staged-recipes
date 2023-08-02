cmake -G "NMake Makefiles" -D XPLUGIN_BUILD_TESTS=OFF -D XPLUGIN_BUILD_DOCS=OFF -D XPLUGIN_BUILD_EXAMPLES=OFF  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
