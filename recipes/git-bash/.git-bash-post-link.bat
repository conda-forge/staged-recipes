@echo off
:: --------------------------------------------------
:: Post install that determines if it was successful:
:: --------------------------------------------------
set "_cwd=%CD%"
cd /d "%PREFIX%\Library\git-bash" || exit /b 1

:: First run of the post install:
set "_err="
.\git-bash.exe --no-needs-console --hide --no-cd --command=post-install.bat 2> _err || exit /b 1
for /f %%i in ("_err") do set _size=%%~zi
if %_size% gtr 0 type _err 1>&2 && exit /b 1
set "_size="

:: Second /dev/stdin bugfix run of the post install:
rmdir /s /q etc\post-install || exit /b 1
mkdir etc\post-install || exit /b 1
move 01-devices.post etc\post-install\01-devices.post > nul || exit /b 1
call .\post-install.bat > nul || exit /b 1

:: First clean up after post install:
del post-install.bat || exit /b 1
rmdir /s /q etc\post-install || exit /b 1

:: Test /dev/stdin bug:
.\bin\bash.exe -c "if [[ $(echo hello | cp /dev/stdin /dev/stdout) != 'hello' ]]; then echo 'bad /dev/stdin' 1>&2; exit 1; fi" || exit /b 1

:: Second clean up after post install:
del _out || exit /b 1
del _err || exit /b 1
cd /d "%_cwd%" || cd "%CD%"
set "_cwd="
