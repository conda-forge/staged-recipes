@echo off
REM Apache Tika CLI wrapper script
REM This script provides a convenient way to run Apache Tika from the command line

set TIKA_JAR=%CONDA_PREFIX%\share\java\apache-tika\tika-app-@VERSION@.jar

if not exist "%TIKA_JAR%" (
    echo Error: tika-app JAR not found at %TIKA_JAR% 1>&2
    exit /b 1
)

java -jar "%TIKA_JAR%" %*
