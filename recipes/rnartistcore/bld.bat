@echo on
:: Enable error handling
setlocal enabledelayedexpansion
set ERRORLEVEL=0

:: --- Build with Maven ---
call mvn clean package || exit /b %ERRORLEVEL%

:: Show what's in target (for debugging)
dir target

:: Create installation directory if needed
mkdir "%CONDA_PREFIX%\share\rnartistcore"

:: Copy the correct jar using the dash version from %JAR_VERSION%
:: This name must match exactly what Maven produces.
copy "target\rnartistcore-%JAR_VERSION%-jar-with-dependencies.jar" ^
     "%CONDA_PREFIX%\share\rnartistcore\rnartistcore.jar" || exit /b %ERRORLEVEL%

java -jar "%~dp0\..\share\rnartistcore\rnartistcore.jar" %*

exit /b 0
