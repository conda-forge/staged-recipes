set DATADIR="%LIBRARY_PREFIX%\share\dcw-gmt"

if not exist %DATADIR% mkdir %DATADIR%

xcopy %SRC_DIR%\*.txt $DATADIR
xcopy %SRC_DIR%\*.TXT $DATADIR
xcopy %SRC_DIR%\COPYING* $DATADIR
xcopy %SRC_DIR%\*.nc %DATADIR% /s /e || exit 1
