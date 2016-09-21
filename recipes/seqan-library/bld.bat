robocopy . "%PREFIX%" /e /w:1 /r:1
if %ERRORLEVEL% GTR 3 exit 1

exit 0
