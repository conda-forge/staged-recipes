@echo on

set DEST_DIR=%LIBRARY_PREFIX%\share\opentelemetry\opentelemetry-proto
mkdir %DEST_DIR%
if %ERRORLEVEL% NEQ 0 exit 1

copy LICENSE %DEST_DIR%
if %ERRORLEVEL% NEQ 0 exit 1

REM robocopy returns non-zero exit codes on success
robocopy /S /E opentelemetry\ %DEST_DIR%\
if %ERRORLEVEL% GEQ 8 exit 1
