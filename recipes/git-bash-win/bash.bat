@echo off
setlocal
for %%a in ("%~dp0") do for %%b in ("%%~dpa.") do set _root=%%~dpb
endlocal
:: %_root%Some_Dir\This_Script.bat
"%_root%Library\git-bash-win\bin\bash.exe" %*
