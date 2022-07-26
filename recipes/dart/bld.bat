robocopy /E "%SRC_DIR%\bin" "%PREFIX%"
if %ERRORLEVEL% GEQ 8 exit 1

robocopy /E "%SRC_DIR%\lib" "%PREFIX%"
if %ERRORLEVEL% GEQ 8 exit 1

robocopy /E "%SRC_DIR%\include" "%PREFIX%"
if %ERRORLEVEL% GEQ 8 exit 1
