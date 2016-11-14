%PREFIX%/wix/candle.exe -?
if %ERRORLEVEL% NEQ 0 exit 1
%PREFIX%/wix/light.exe -?
if %ERRORLEVEL% NEQ 0 exit 1

exit 0
