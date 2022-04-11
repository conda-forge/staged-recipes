setlocal EnableDelayedExpansion
@echo on

cd build
if errorlevel 1 exit 1

:: call install script directly because executing the install target re-builds
:: (in that case, the re-build happens because timestamps have changed)

if [%PKG_NAME:~0,10%] == [libbladerf] (
    :: install full library
    cmake -P host\libraries\libbladeRF\cmake_install.cmake
    if errorlevel 1 exit 1
    :: move dll to proper location
    cmake -E rename %LIBRARY_PREFIX%\lib\bladeRF-2.dll %LIBRARY_PREFIX%\bin\bladeRF-2.dll
    if errorlevel 1 exit 1
    if not [%PKG_NAME%] == [libbladerf] (
        :: install numbered library only (delete import lib and headers)
        cmake -E rm -f %LIBRARY_PREFIX%\include\bladeRF1.h
        cmake -E rm -f %LIBRARY_PREFIX%\include\bladeRF2.h
        cmake -E rm -f %LIBRARY_PREFIX%\include\libbladeRF.h
        cmake -E rm -f %LIBRARY_PREFIX%\lib\pkgconfig\libbladeRF.pc
        cmake -E rm -f %LIBRARY_PREFIX%\lib\bladeRF.lib
        if errorlevel 1 exit 1
    )
) else if [%PKG_NAME%] == [bladerf] (
    cmake -P cmake_install.cmake
    if errorlevel 1 exit 1
    :: remove dll in improper location
    cmake -E rm -f %LIBRARY_PREFIX%\lib\bladeRF-2.dll
    if errorlevel 1 exit 1
)
