set BUILD_DIR=%SRC_DIR%\bld
mkdir %BUILD_DIR%
cd %BUILD_DIR%

REM Configure Step
cmake -G "Ninja" ^
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON ^
    -D BUILD_SHARED_LIBS:BOOL=ON ^
    -D BUILD_TESTING:BOOL=OFF ^
    -D BUILD_EXAMPLES:BOOL=OFF ^
    -D WRAP_DEFAULT:BOOL=OFF ^
    -D SimpleITK_EXPLICIT_INSTANTIATION:BOOL=ON ^
    -D "CMAKE_SYSTEM_PREFIX_PATH:PATH=%LIBRARY_PREFIX%" ^
    -D "CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%" ^
    "%SRC_DIR%/SuperBuild"

if errorlevel 1 exit 1

REM Build step
cmake --build  . --config Release
if errorlevel 1 exit 1

REM Install step
cmake -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1


