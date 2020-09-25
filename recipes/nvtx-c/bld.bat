@echo ON

rem Copy over the include dir
robocopy c\include\nvtx3 "%LIBRARY_INC%"\nvtx3 /e
if %ERRORLEVEL% GEQ 8 exit 1

exit 0
