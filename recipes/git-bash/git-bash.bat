@echo off
set "_name=git-bash"
set "_dir="

set "_bash_dir=%~dp0\..\Library\%_name%"
if not exist "%_bash_dir%\post-install.bat" goto skip
"%_bash_dir%\git-bash.exe" --no-needs-console --hide --no-cd ^
  --command="%_bash_dir%\post-install.bat" > nul || exit /b 1
del "%_bash_dir%\post-install.bat" || exit /b 1

:skip
"%_bash_dir%\%_dir%%~n0.exe" %*
:: the first successful run of %~n0.bat would overwrite it:
echo @"%%~dp0\..\Library\%_name%\%_dir%%~n0.exe" %%* > "%~dp0\%~n0.bat"
