@echo on
setlocal enabledelayedexpansion

set "INSTALL_DIR=%PREFIX%\share\%PKG_NAME%"
mkdir "%INSTALL_DIR%"

REM Build with the Gradle wrapper (downloads Gradle + dependencies from Maven Central)
call gradlew.bat :hydra-java:build :hydra-ext:build -x test --no-daemon --stacktrace
if errorlevel 1 exit /b 1

REM Copy project JARs
for %%f in (hydra-java\build\libs\*.jar) do copy "%%f" "%INSTALL_DIR%\"
for %%f in (hydra-ext\build\libs\*.jar) do copy "%%f" "%INSTALL_DIR%\" 2>nul

REM Copy runtime dependencies via a Gradle init script
set "INIT_SCRIPT=%TEMP%\copy-deps.gradle"
(
echo allprojects {
echo     tasks.register('copyDeps', Copy^) {
echo         from configurations.runtimeClasspath
echo         into System.getenv('INSTALL_DIR'^)
echo         duplicatesStrategy = DuplicatesStrategy.EXCLUDE
echo     }
echo }
) > "%INIT_SCRIPT%"

call gradlew.bat :hydra-java:copyDeps --init-script "%INIT_SCRIPT%" --no-daemon
if errorlevel 1 exit /b 1

REM Install wrapper script
mkdir "%PREFIX%\Library\bin" 2>nul
copy "%RECIPE_DIR%\wrapper.bat" "%PREFIX%\Library\bin\hydra-java.cmd"
if errorlevel 1 exit /b 1
