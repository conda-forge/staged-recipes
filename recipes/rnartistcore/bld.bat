@echo on
:: Enable error handling
setlocal enabledelayedexpansion
set ERRORLEVEL=0

:: Build the project using Maven
call mvn clean package || exit /b %ERRORLEVEL%

:: Create installation directory
mkdir "%PREFIX%\\share\\rnartistcore"

:: Copy the built JAR file to the installation directory
copy target\\rnartistcore-*-jar-with-dependencies.jar "%PREFIX%\\share\\rnartistcore\\rnartistcore.jar"

exit /b 0
