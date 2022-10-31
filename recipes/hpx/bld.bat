mkdir build
cd build
if %errorlevel% neq 0 exit /b %errorlevel%

cmake %SRC_DIR% ^
    -G "NMake Makefiles" ^
    -D CMAKE_BUILD_TYPE="Release" ^
    -D CMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_INSTALL_LIBDIR=lib ^
    -D HPX_WITH_EXAMPLES=FALSE ^
    -D HPX_WITH_MALLOC="mimalloc" ^
    -D HPX_WITH_NETWORKING=FALSE ^
    -D HPX_WITH_TESTS=FALSE
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build . --config Release --parallel %CPU_COUNT%
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --install .
if %errorlevel% neq 0 exit /b %errorlevel%
