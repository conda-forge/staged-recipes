set BUILD_DIR=%SRC_DIR%
mkdir %BUILD_DIR%
cd %BUILD_DIR%

REM Configure Step
cmake -G "Ninja" ^
    -D BUILD_SHARED_LIBS:BOOL=ON ^
    -D BUILD_TESTING:BOOL=OFF ^
    -D BUILD_EXAMPLES:BOOL=OFF ^
    -D ITK_USE_SYSTEM_EXPAT:BOOL=ON ^
    -D ITK_USE_SYSTEM_HDF5:BOOL=ON ^
    -D ITK_USE_SYSTEM_JPEG:BOOL=ON ^
    -D ITK_USE_SYSTEM_PNG:BOOL=ON ^
    -D ITK_USE_SYSTEM_TIFF:BOOL=ON ^
    -D ITK_USE_SYSTEM_ZLIB:BOOL=ON ^
    -D ITK_USE_KWSTYLE:BOOL=OFF ^
    -D ITK_BUILD_DEFAULT_MODULES:BOOL=ON ^
    -D Module_ITKReview:BOOL=ON ^
    -D "CMAKE_SYSTEM_PREFIX_PATH:PATH=%LIBRARY_PREFIX%" ^
    -D "CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%" ^
    "%SRC_DIR%"

if errorlevel 1 exit 1

REM Build step
cmake --build  . --config Release
if errorlevel 1 exit 1

REM Install step
cmake -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -P %BUILD_DIR%/cmake_install.cmake
if errorlevel 1 exit 1
