set "src=%SRC_DIR%\%PKG_NAME%"
COPY %src%\info\LICENSE.txt %SRC_DIR%
robocopy /E "%src%" "%PREFIX%"
if %ERRORLEVEL% GEQ 8 exit 1

:: replace old info folder with our new regenerated one
rd /s /q %PREFIX%\info