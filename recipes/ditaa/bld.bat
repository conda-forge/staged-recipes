:: Copy additional license files into the source directory so that
:: conda-build can package them via the license_file entries in meta.yaml
copy %RECIPE_DIR%\GPL-3.0.txt .
copy %RECIPE_DIR%\NOTICE .

:: Work around a conda-forge leiningen packaging bug on Windows where LEIN_VERSION
:: is empty in the installed lein.bat, causing it to look for leiningen--standalone.jar.
:: Pre-setting LEIN_JAR causes lein.bat to skip its broken path construction.
for %%f in ("%BUILD_PREFIX%\lib\leiningen\libexec\leiningen-*-standalone.jar") do set "LEIN_JAR=%%f"
if "x%LEIN_JAR%" == "x" (
    echo ERROR: Could not locate leiningen standalone jar in %BUILD_PREFIX%\lib\leiningen\libexec\
    exit /B 1
)
echo Using LEIN_JAR=%LEIN_JAR%

:: Build the uberjar using lein from the conda-forge leiningen package
CALL lein uberjar

:: Install the jar
set JAR=ditaa-0.11.0-standalone.jar
if not exist "%LIBRARY_LIB%" mkdir "%LIBRARY_LIB%"
copy .\target\%JAR% %LIBRARY_LIB%\ || exit 1
rename %LIBRARY_LIB%\%JAR% ditaa.jar

:: Create the wrapper script using a relative path so it works regardless
:: of where the conda environment is installed
if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
(
  echo @echo off
  echo set "SCRIPT_DIR=%%~dp0"
  echo java -ea -jar "%%SCRIPT_DIR%%..\lib\ditaa.jar" %%*
) > "%LIBRARY_BIN%\ditaa.bat"

:: Install NOTICE for user reference
if not exist "%PREFIX%\share\ditaa" mkdir "%PREFIX%\share\ditaa"
copy %RECIPE_DIR%\NOTICE %PREFIX%\share\ditaa\
