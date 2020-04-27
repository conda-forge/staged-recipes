FOR /F "delims=" %%i in ('cygpath.exe -u "%PREFIX%"') DO set "pfx=%%i"
bash install.sh --prefix=%pfx%/Library
if errorlevel 1 exit 1