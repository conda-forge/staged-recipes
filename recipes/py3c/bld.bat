:: Generate a Unixy path for bash.
set "WIN_PREFIX=%PREFIX%"
for /f "delims=" %%i in ('cygpath.exe -u -p "%LIBRARY_PREFIX%"') do (
    set "UNIX_PREFIX=%%i"
)

:: Reuse the Unix build to get a Windows build simply.
set "PREFIX=%UNIX_PREFIX%"
bash -x %RECIPE_DIR%\build.sh
if errorlevel 1 exit 1
set "PREFIX=%WIN_PREFIX%"

:: No need for pkg-config files on Windows.
rmdir /s /q "%LIBRARY_PREFIX%\share"
if errorlevel 1 exit 1
