@echo off

if not defined CMAKE_GENERATOR_TOOLSET (
    echo ERROR: Compiler activation did not set CMAKE_GENERATOR_TOOLSET.
    exit /b 1
)

msbuild libserialport.sln /m:%CPU_COUNT% /p:Configuration=Release /p:Platform=x64 /p:PlatformToolset=%CMAKE_GENERATOR_TOOLSET% /p:OutDir=build\
if errorlevel 1 exit /b 1

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
if errorlevel 1 exit /b 1
if not exist "%LIBRARY_LIB%" mkdir "%LIBRARY_LIB%"
if errorlevel 1 exit /b 1
if not exist "%LIBRARY_INC%" mkdir "%LIBRARY_INC%"
if errorlevel 1 exit /b 1

copy /Y "build\libserialport.dll" "%LIBRARY_BIN%\libserialport.dll"
if errorlevel 1 exit /b 1
copy /Y "build\libserialport.lib" "%LIBRARY_LIB%\libserialport.lib"
if errorlevel 1 exit /b 1
copy /Y "libserialport.h" "%LIBRARY_INC%\libserialport.h"
if errorlevel 1 exit /b 1
