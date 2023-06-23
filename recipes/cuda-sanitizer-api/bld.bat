@echo on

if not exist %PREFIX% mkdir %PREFIX%
if not exist %LIBRARY_PREFIX% mkdir %LIBRARY_PREFIX%
if not exist %SCRIPTS% mkdir %SCRIPTS%

rmdir /q /s compute-sanitizer\x86
if errorlevel 1 exit 1

move compute-sanitizer %LIBRARY_PREFIX%
if errorlevel 1 exit 1

:: Create bat links for all exe files in %LIBRARY_PREFIX%\compute-sanitizer
cd %SCRIPTS%
for /r "%LIBRARY_PREFIX%\compute-sanitizer" %%f in (*.exe) do (
    echo @echo off > %%~nf.bat
    echo %%~dp0..\Library\compute-sanitizer\%%~nf.exe %%* >> %%~nf.bat
    if errorlevel 1 exit 1
)
