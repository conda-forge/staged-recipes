"%R%" CMD INSTALL --build --configure-args='--novendor' .
if %ERRORLEVEL% neq 0 exit 1
