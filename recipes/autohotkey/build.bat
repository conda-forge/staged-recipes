@echo on

set "MSBUILD_ARGS=/nologo /m /p:Configuration=Release /p:RawAhkVersion=%PKG_VERSION%"

msbuild AutoHotkeyx.sln /p:Platform=x64 %MSBUILD_ARGS%
if %ERRORLEVEL% neq 0 exit /b 1

msbuild AutoHotkeyx.sln /p:Platform=Win32 %MSBUILD_ARGS%
if %ERRORLEVEL% neq 0 exit /b 1

copy /y bin\AutoHotkey64.exe "%LIBRARY_BIN%\"
if %ERRORLEVEL% neq 0 exit /b 1

copy /y bin\AutoHotkey32.exe "%LIBRARY_BIN%\"
if %ERRORLEVEL% neq 0 exit /b 1
