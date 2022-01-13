setlocal EnableDelayedExpansion
@echo on

cd host
cd build
if errorlevel 1 exit 1

:: call install script directly because executing the install target re-builds
:: (in that case, the re-build happens because timestamps have changed)

if [%PKG_NAME:~0,9%] == [libhackrf] (
    if [%PKG_NAME%] == [libhackrf] (
        :: install full library
        cmake -P libhackrf\cmake_install.cmake
        if errorlevel 1 exit 1
        :: move import lib to proper location
        cmake -E rename %LIBRARY_PREFIX%\bin\hackrf.lib %LIBRARY_PREFIX%\lib\hackrf.lib
        if errorlevel 1 exit 1
    ) else (
        :: install numbered library only (delete import lib and headers)
        cmake -P libhackrf\src\cmake_install.cmake
        if errorlevel 1 exit 1
        cmake -E rm -f %LIBRARY_PREFIX%\bin\hackrf.lib %LIBRARY_PREFIX%\include\libhackrf\hackrf.h
        if errorlevel 1 exit 1
    )
    :: remove static library, per CFEP-18
    cmake -E rm -f %LIBRARY_PREFIX%\bin\hackrf_static.lib
    if errorlevel 1 exit 1
) else if [%PKG_NAME%] == [hackrf] (
    cmake -P hackrf-tools\cmake_install.cmake
    if errorlevel 1 exit 1
)
