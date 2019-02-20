@echo off
set "_name=git-bash"
set "_dir=bin\"

set "_bash_dir=%~dp0\..\Library\%_name%"
if not exist "%_bash_dir%\post-install.bat" goto skip

:: post install:
set "_CWD=%CD%"
cd /d "%_bash_dir%" || exit /b 1
.\git-bash.exe --no-needs-console --hide --no-cd --command=post-install.bat > nul || exit /b 1
del "%_bash_dir%\post-install.bat" || exit /b 1
cd /d "%_CWD%"

:skip
"%_bash_dir%\%_dir%%~n0.exe" %*
:: the first successful run of %~n0.bat would overwrite it:
echo @"%%~dp0\..\Library\%_name%\%_dir%%~n0.exe" %%* > "%~dp0\%~n0.bat"
