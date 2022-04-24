cmake -G "NMake Makefiles" -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D Boost_USE_STATIC_LIBS=OFF -D Boost_USE_STATIC_RUNTIME=OFF -D QL_BUILD_EXAMPLES=OFF -D QL_BUILD_BENCHMARK=OFF %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
