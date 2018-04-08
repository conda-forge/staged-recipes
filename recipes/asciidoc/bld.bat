@echo ON

robocopy %SRC_DIR%\ %LIBRARY_LIB%\ *.* /E /SL
if %ERRORLEVEL% GEQ 8 exit 1

exit 0
