set DATADIR="%LIBRARY_PREFIX%\share\gshhg-gmt"

if not exist %DATADIR% mkdir %DATADIR%

xcopy %SRC_DIR%\*.nc %DATADIR% /s /e || exit 1
xcopy %SRC_DIR%\*.TXT %DATADIR% /s /e || exit 1
xcopy %SRC_DIR%\COPYING* %DATADIR% /s /e || exit 1
