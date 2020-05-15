@echo ON

rem Copy over the include dir
robocopy cub "%LIBRARY_INC%"\cub /e
if %ERRORLEVEL% GEQ 8 exit 1

exit 0
