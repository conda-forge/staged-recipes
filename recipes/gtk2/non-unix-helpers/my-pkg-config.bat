@echo off

REM Path to the real pkg-config
FOR /F "delims=" %%A IN ('where pkg-config.exe') DO SET "REAL_PKG_CONFIG=%%A"

REM Log file (must be manually set because RECIPE_DIR is undefined in .bat)
SET "LOG_FILE=%RECIPE_DIR%\pkg-config-windebug.log"

REM Get current date and time for logging
FOR /F "tokens=2 delims==" %%A IN ('wmic os get localdatetime /value 2^>nul') DO SET "DATETIME=%%A"
SET "DATETIME=%DATETIME:~0,4%-%DATETIME:~4,2%-%DATETIME:~6,2% %DATETIME:~8,2%:%DATETIME:~10,2%:%DATETIME:~12,2%"

REM Log the arguments passed to pkg-config
ECHO [%DATETIME%] Arguments: %* >> "%LOG_FILE%"

REM Run the real pkg-config and capture output
FOR /F "delims=" %%A IN ('"%REAL_PKG_CONFIG%" %* 2^>^&1') DO SET "OUTPUT=%%A"

REM Log the output from pkg-config
ECHO [%DATETIME%] Output: %OUTPUT% >> "%LOG_FILE%"

REM Print the output to stdout so calling tools work
ECHO %OUTPUT%

REM Log PKG_CONFIG_PATH for debugging
ECHO [%DATETIME%] PKG_CONFIG_PATH: %PKG_CONFIG_PATH% >> "%LOG_FILE%"

REM Exit with the same status as the real pkg-config
EXIT /B %ERRORLEVEL%
