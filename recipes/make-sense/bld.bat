FOR /F "delims=" %%i IN ('npm pack') DO set "tgz=%%i"
npm install -g %tgz%