setlocal EnableDelayedExpansion
@echo on

cd forgebuild
if errorlevel 1 exit 1

:: call install script directly because executing the install target re-builds
:: (in that case, the re-build happens because timestamps have changed)

if [%PKG_NAME%] == [libairspyhf] (
    cmake -P libairspyhf\cmake_install.cmake
    if errorlevel 1 exit 1
    :: don't install static libraries
    del %LIBRARY_PREFIX%\bin\airspyhf_static.lib
    if errorlevel 1 exit 1
    :: move import lib to proper location
    move %LIBRARY_PREFIX%\bin\airspyhf.lib %LIBRARY_PREFIX%\lib\airspyhf.lib
    if errorlevel 1 exit 1
) else if [%PKG_NAME%] == [airspyhf] (
    cmake -P tools\cmake_install.cmake
    if errorlevel 1 exit 1
)
