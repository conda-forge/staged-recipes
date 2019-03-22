@echo on
set BUILD_DIR=%SRC_DIR%\b
mkdir %BUILD_DIR%
cd %BUILD_DIR%

REM enable parallel MSVC build and override default -GL option
SET CXXFLAGS=/MP
SET CFLAGS=/MP


REM Configure Step
cmake -G "Ninja" ^
    -D CMAKE_BUILD_TYPE:STRING=Release ^
    -D BUILD_SHARED_LIBS:BOOL=OFF ^
    -D BUILD_TESTING:BOOL=OFF ^
    -D BUILD_EXAMPLES:BOOL=OFF ^
    -D WRAP_DEFAULT:BOOL=OFF ^
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON ^
    -D SimpleITK_USE_SYSTEM_SWIG:BOOL=ON ^
    -D SimpleITK_USE_SYSTEM_ITK:BOOL=ON ^
    -D SimpleITK_EXPLICIT_INSTANTIATION:BOOL=ON ^
    -D SimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF ^
    -D "CMAKE_SYSTEM_PREFIX_PATH:PATH=%LIBRARY_PREFIX%" ^
    -D "CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%" ^
    "%SRC_DIR%/SuperBuild"

if errorlevel 1 (
   type CMakeFiles/CMakeOutput.log
   exit 1
)


REM Build step
cmake --build  . --config Release
if errorlevel 1 (
   type CMakeCache.txt
   exit 1
)


REM Install step
cmake -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -P %BUILD_DIR%\SimpleITK-build\cmake_install.cmake
if errorlevel 1 exit 1
