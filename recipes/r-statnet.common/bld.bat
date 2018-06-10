set BINPREF=%BUILD_PREFIX%/Library/mingw-w64/bin/
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1
