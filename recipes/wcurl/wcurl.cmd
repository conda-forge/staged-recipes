@echo off

REM Determine the path of the wcurl script
set "WCURL_PATH=%LIBRARY_BIN%\wcurl"

REM Run the wcurl script with Bash
bash "%WCURL_PATH%" %*
