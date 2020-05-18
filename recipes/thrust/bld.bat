@echo ON

rem Copy over the include dir
robocopy thrust "%LIBRARY_INC%"\thrust /e
if %ERRORLEVEL% GEQ 8 exit 1

exit 0
