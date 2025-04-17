@echo on
:: Enable error handling
setlocal enabledelayedexpansion
set ERRORLEVEL=0

:: --- Build with Maven ---
call mvn clean package || exit /b %ERRORLEVEL%

:: Generate a THIRD-PARTY license report
echo Running Maven license plugin with goal: aggregate-third-party-report
call mvn org.codehaus.mojo:license-maven-plugin:1.19:aggregate-third-party-report || exit /b %ERRORLEVEL%

:: Show what's in target (for debugging)
dir target

:: Create installation directory if needed
mkdir "%PREFIX%\share\rnartistcore"

:: Copy the correct jar using the dash version from %JAR_VERSION%
copy "target\rnartistcore-%JAR_VERSION%-jar-with-dependencies.jar" ^
     "%PREFIX%\share\rnartistcore\rnartistcore.jar" || exit /b %ERRORLEVEL%

:: Copy the third‑party license report to the package root
copy "target\generated-sources\license\THIRD-PARTY.txt" ^
     "%PREFIX%\THIRD-PARTY.txt" || exit /b %ERRORLEVEL%

exit /b 0
