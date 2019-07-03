set DATADIR="%LIBRARY_PREFIX%\\share\\proj"
if not exist %DATADIR% mkdir %DATADIR%

xcopy %PKG_NAME%\*  %DATADIR% /s /e || exit 1
