robocopy . "%PREFIX%" /S /XF bld.bat
if errorlevel NEQ 1 exit 1

exit 0
