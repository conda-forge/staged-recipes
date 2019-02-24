@echo off
if not exist "%~dp0\..\Library\git-bash\post-install.bat" goto skip

:: --------------------------------------------------
:: Post install that determines if it was successful:
:: --------------------------------------------------
set "_cwd=%CD%" && cd /d "%~dp0\..\Library\git-bash" || exit /b 1

:: First run of the post install:
set "_err="
.\git-bash.exe --no-needs-console --hide --no-cd --command=post-install.bat > _out 2> _err ^
    || set "_err=1" && cd "%CD%"
for /f %%i in ("_err") do set _size=%%~zi
if %_size% gtr 0 set "_err=1"
set "_size="

:: Second /dev/stdin bugfix run of the post install:
rmdir /s /q etc\post-install ^
    || set "_err=1" && cd "%CD%"
mkdir etc\post-install ^
    || set "_err=1" && cd "%CD%"
move 01-devices.post etc\post-install\01-devices.post > nul ^
    || set "_err=1" && cd "%CD%"
call .\post-install.bat > nul ^
    || set "_err=1" && cd "%CD%"

:: First clean up after post install:
del post-install.bat ^
    || set "_err=1" && cd "%CD%"
rmdir /s /q etc\post-install ^
    || set "_err=1" && cd "%CD%"

:: Test /dev/stdin bug:
.\bin\bash.exe -c "if [[ $(echo hello | cp /dev/stdin /dev/stdout) != 'hello' ]]; then echo 'bad /dev/stdin' 1>&2; exit 1; fi" ^
    > nul || set "_err=1" && cd "%CD%"

:: Second clean up after post install:
if defined _err (
    echo git bash post install failed 1>&2
    type _err 1>&2
    type _out
    echo @exit /b 1 > "%~dp0\git-bash-post-install.bat"
) else (
    echo @exit /b 0 > "%~dp0\git-bash-post-install.bat"
)
del _out || cd "%CD%"
del _err || cd "%CD%"
cd /d "%_cwd%"
set "_cwd="

:: Exit with error if post install failed:
if defined _err set "_err=" && exit /b 1

:: ---------------------
:: Running git-bash.exe:
:: ---------------------
:skip
"%~dp0\..\Library\git-bash\%~n0.exe" %*
:: First successful run of the %~f0 would overwrite it:
echo @"%%~dp0\..\Library\git-bash\%~n0.exe" %%* > "%~f0"
