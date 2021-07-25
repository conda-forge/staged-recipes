setlocal EnableDelayedExpansion
@echo on

cd forgebuild
if errorlevel 1 exit 1

:: call install script directly because executing the install target re-builds
:: (in that case, the re-build happens because timestamps have changed)

if [%PKG_NAME%] == [libairspy] (
    cmake -P libairspy\cmake_install.cmake
    if errorlevel 1 exit 1
    :: don't install static libraries
    del %LIBRARY_PREFIX%\bin\airspy_static.lib
    if errorlevel 1 exit 1
    :: move import lib to proper location
    move %LIBRARY_PREFIX%\bin\airspy.lib %LIBRARY_PREFIX%\lib\airspy.lib
    if errorlevel 1 exit 1
) else if [%PKG_NAME%] == [airspy] (
    cmake -P airspy-tools\cmake_install.cmake
    if errorlevel 1 exit 1
)
