@echo off
if not exist "%~dp0\..\Library\git-bash\post-install.bat" goto skip

:: post-install:
set "_cwd=%CD%" && cd /d "%~dp0\..\Library\git-bash" || exit 1
set "_err="
.\git-bash.exe --no-needs-console --hide --no-cd --command=post-install.bat > _out 2> _err ^
|| set "_err=true" && cd /d "%CD%"
for /f %%i in ("_err") do set _size=%%~zi
if %_size% gtr 0 set "_err=true"
set "_size="
if defined _err (
    echo git bash post install failed 1>&2
    type _err 1>&2
    type _out
    echo @exit /b 1 > "%~dp0\git-bash-post-install.bat"
) else (
    echo @exit /b 0 > "%~dp0\git-bash-post-install.bat"
)
del post-install.bat || exit /b 1
rmdir /s /q .\etc\post-install || exit /b 1
del _out || exit /b 1
del _err || exit /b 1
cd /d "%_cwd%"
set "_cwd="
if defined _err set "_err=" && exit /b 1

:skip
"%~dp0\..\Library\git-bash\bin\%~n0.exe" %*
:: the first successful run of %~n0.bat would overwrite it:
echo @"%%~dp0\..\Library\git-bash\bin\%~n0.exe" %%* > "%~dp0\%~n0.bat"
