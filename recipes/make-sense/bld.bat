FOR /F "delims=" %%i IN ('npm pack') DO set "tgz=%%i"
if errorlevel 1 exit 1
npm install -g %tgz%
if errorlevel 1 exit 1