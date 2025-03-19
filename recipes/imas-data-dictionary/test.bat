@echo off

:: Confirm if idsinfo command is available
idsinfo --help
if %errorlevel% neq 0 (
    echo idsinfo command not found
    exit /b 1
)

:: Confirm required environment variables are set
echo IMAS_VERSION: %IMAS_VERSION%
echo IMAS_PREFIX: %IMAS_PREFIX%

:: Confirm if the environment variables are set correctly
if "%IMAS_VERSION%"=="%PKG_VERSION%" (
    echo IMAS_VERSION is set correctly
) else (
    echo IMAS_VERSION is not set correctly
    exit /b 1
)

for /f "delims=" %%i in ('idsinfo idspath') do set IDSPATH=%%i
if "%IMAS_PREFIX%\include\IDSDef.xml"=="%IDSPATH%" (
    echo IMAS_PREFIX is set correctly
) else (
    echo IMAS_PREFIX is not set correctly
    exit /b 1
)
