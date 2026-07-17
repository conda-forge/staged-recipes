@echo on
setlocal EnableExtensions

rem Dependencies and the pinned license-report plugin are intentionally
rem resolved over the network. Gradle itself is supplied by conda-forge.
set "GRADLE_USER_HOME=%SRC_DIR%\.gradle-conda"
if not exist "%BUILD_PREFIX%\bioformats2raw-tmp" mkdir "%BUILD_PREFIX%\bioformats2raw-tmp"
set "JAVA_TOOL_OPTIONS=-Djava.io.tmpdir=%BUILD_PREFIX%\bioformats2raw-tmp"
call gradle.bat --no-daemon --stacktrace clean test installDist generateLicenseReport
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\share\bioformats2raw" mkdir "%PREFIX%\share\bioformats2raw"
xcopy /E /I /Y "build\install\bioformats2raw\*" "%PREFIX%\share\bioformats2raw\"
if errorlevel 1 exit /b 1

if not exist "%SCRIPTS%" mkdir "%SCRIPTS%"
echo @call "%%~dp0..\share\bioformats2raw\bin\bioformats2raw.bat" %%* > "%SCRIPTS%\bioformats2raw.bat"
