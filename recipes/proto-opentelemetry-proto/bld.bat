@echo on

set DEST_DIR=%LIBRARY_PREFIX%\share\opentelemetry\opentelemetry-proto
mkdir %DEST_DIR%
if %ERRORLEVEL% NEQ 0 exit 1

copy LICENSE %DEST_DIR%
if %ERRORLEVEL% NEQ 0 exit 1

robocopy /S /E opentelemetry\ %DEST_DIR%\
if %ERRORLEVEL% NEQ 0 exit 1
