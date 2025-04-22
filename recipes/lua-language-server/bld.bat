@echo on
setlocal EnableDelayedExpansion

REM Fail fast
set ERRLEV=0
call :main || set ERRLEV=1
exit /B !ERRLEV!

:main
REM Change to luamake directory and build
pushd 3rd\luamake
call compile\build.bat notest
popd

REM Use luamake to rebuild with specified tools
3rd\luamake\luamake.exe -cc "%CC%" -ar "%AR%" -cflags "%CFLAGS%" rebuild -notest

REM Create necessary directories
mkdir %PREFIX%\libexec\%PKG_NAME%
mkdir %PREFIX%\libexec\%PKG_NAME%\bin
mkdir %PREFIX%\libexec\%PKG_NAME%\log
mkdir %PREFIX%\bin

REM Copy binaries and resources
copy /Y bin\%PKG_NAME% %PREFIX%\libexec\%PKG_NAME%\bin\
copy /Y bin\main.lua %PREFIX%\libexec\%PKG_NAME%\bin\
copy /Y main.lua %PREFIX%\libexec\%PKG_NAME%\
copy /Y debugger.lua %PREFIX%\libexec\%PKG_NAME%\
xcopy /E /I /Y locale %PREFIX%\libexec\%PKG_NAME%\locale
xcopy /E /I /Y meta %PREFIX%\libexec\%PKG_NAME%\meta
xcopy /E /I /Y script %PREFIX%\libexec\%PKG_NAME%\script
copy /Y changelog.md %PREFIX%\libexec\%PKG_NAME%\

REM Create a wrapper batch script for Windows
(
    echo @echo off
    echo "%PREFIX%\libexec\%PKG_NAME%\bin\%PKG_NAME%" %%*
) > %PKG_NAME%.bat

copy /Y %PKG_NAME%.bat %PREFIX%\bin\
goto :eof
