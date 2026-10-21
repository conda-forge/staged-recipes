@echo on

cd src\win32
if errorlevel 1 exit /b 1

cscript //NoLogo configure.js
if errorlevel 1 exit /b 1

if not defined CMAKE_GENERATOR_TOOLSET (
    echo ERROR: Compiler activation did not set CMAKE_GENERATOR_TOOLSET.
    exit /b 1
)

msbuild modbus-9.sln /m:%CPU_COUNT% /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=%CMAKE_GENERATOR_TOOLSET%
if errorlevel 1 exit /b 1

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
if errorlevel 1 exit /b 1
if not exist "%LIBRARY_LIB%" mkdir "%LIBRARY_LIB%"
if errorlevel 1 exit /b 1
if not exist "%LIBRARY_INC%\\modbus" mkdir "%LIBRARY_INC%\\modbus"
if errorlevel 1 exit /b 1

copy /Y "modbus.dll" "%LIBRARY_BIN%\\modbus.dll"
if errorlevel 1 exit /b 1
copy /Y "modbus.lib" "%LIBRARY_LIB%\\modbus.lib"
if errorlevel 1 exit /b 1
copy /Y "..\\modbus.h" "%LIBRARY_INC%\\modbus\\modbus.h"
if errorlevel 1 exit /b 1
copy /Y "..\\modbus-rtu.h" "%LIBRARY_INC%\\modbus\\modbus-rtu.h"
if errorlevel 1 exit /b 1
copy /Y "..\\modbus-tcp.h" "%LIBRARY_INC%\\modbus\\modbus-tcp.h"
if errorlevel 1 exit /b 1
copy /Y "..\\modbus-version.h" "%LIBRARY_INC%\\modbus\\modbus-version.h"
if errorlevel 1 exit /b 1
