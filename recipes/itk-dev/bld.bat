# Building ITK inside the conda-build directory creates excessively
# long paths. Due to the number of includes for needed during ITK, the
# command line exceed the system limits. So a short build directory is
# required.
set BUILD_DIR=C:\b\%PY_VER%-%ARCH%
IF EXIST %BUILD_DIR% ( echo "Please remove %BUILD_DIR%"; exit 1 )
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
    -D "CMAKE_SYSTEM_PREFIX_PATH:PATH=%PREFIX%/Library" ^
    -D "CMAKE_INSTALL_PREFIX=%PREFIX%" ^
    "%SRC_DIR%"

if errorlevel 1 exit 1

REM Build step
cmake --build  . --config Release
if errorlevel 1 exit 1

REM Install step
cmake -D CMAKE_INSTALL_PREFIX=%PREFIX% -P %BUILD_DR%/cmake_install.cmake
if errorlevel 1 exit 1
