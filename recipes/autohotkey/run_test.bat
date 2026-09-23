@echo on

AutoHotkey64.exe /ErrorStdOut run_test.ahk %PKG_VERSION%
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

AutoHotkey32.exe /ErrorStdOut run_test.ahk %PKG_VERSION%
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
