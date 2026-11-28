@echo on
:: Builds q3map2 on Windows with conda-forge's MinGW-w64 GCC (UCRT) using the
:: standalone CMake project in cmake on top of the extracted
:: netradiant-custom sources (%SRC_DIR%).
::
:: The compilers (including windres, set by the binutils activation) are
:: passed explicitly, so CMake does not pick up MSVC or another MinGW from
:: the runner image. conda packages install into %LIBRARY_PREFIX% on Windows.

:: Build from within the source tree, so object file paths stay relative
:: (and below the Windows MAX_PATH limit)
copy /Y "%RECIPE_DIR%\cmake\CMakeLists.txt" "%SRC_DIR%\CMakeLists.txt"
if errorlevel 1 exit 1

cmake -S "%SRC_DIR%" -B build -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_C_COMPILER=%CC% ^
    -DCMAKE_CXX_COMPILER=%CXX% ^
    -DCMAKE_RC_COMPILER=%WINDRES% ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DNETRADIANT_SOURCE_DIR="%SRC_DIR%" ^
    -DQ3MAP2_VERSION_SUFFIX="%PKG_VERSION%"
if errorlevel 1 exit 1

cmake --build build --verbose
if errorlevel 1 exit 1

cmake --install build --strip
if errorlevel 1 exit 1
