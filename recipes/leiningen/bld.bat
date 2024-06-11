@echo off
setlocal EnableDelayedExpansion

set "version=%PKG_VERSION%"
set "bin_dir=%PREFIX%\Scripts"
set "lein_file=%RECIPE_DIR%\scripts\lein.bat"

set "temp_file=lein_temp.bat"

for /f "delims=" %%i in (%lein_file%) do (
    set "line=%%i"
    if "!line:~0,13!"=="set LEIN_VERSION" (
        echo set LEIN_VERSION=%PKG_VERSION%>> "%temp_file%"
    ) else (
        echo %%i>> "%temp_file%"
    )
)

move /Y "%temp_file%" "%lein_file%"
if errorlevel 1 exit 1

set LIBEXEC_DIR=%PREFIX%\lib\leiningen\libexec
mkdir %LIBEXEC_DIR%
copy %SRC_DIR%\leiningen-jar\leiningen-%PKG_VERSION%-standalone.jar %LIBEXEC_DIR%\leiningen-%PKG_VERSION%-standalone.jar > nul
if errorlevel 1 exit 1
echo copied :PREFIX:\lib\leiningen\libexec\leiningen-%PKG_VERSION%-standalone.jar

mkdir %PREFIX%\Scripts
copy %RECIPE_DIR%\scripts\lein.bat %PREFIX%\Scripts\lein.bat > nul
if errorlevel 1 exit 1
echo copied :PREFIX:\Scripts\lein.bat

set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
mkdir %ACTIVATE_DIR%
copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\lein-activate.bat > nul
if errorlevel 1 exit 1
echo copied :ACTIVATE_DIR:\lein-activate.bat

:: At this point we have a working Leiningen
:: We rebuild from source to add the THIRD-PARTY.txt file
cd "%SRC_DIR%"\leiningen-src\leiningen-core
  echo "Bootstrapping ...
  set "LEIN_JAR=%PREFIX%\lib\leiningen\libexec\leiningen-%PKG_VERSION%-standalone.jar"
  call lein bootstrap
  if errorlevel 1 exit 1
  echo "Third party licenses ...
  call mvn license:add-third-party -Dlicense.thirdPartyFile=THIRD-PARTY.txt > nul
  if errorlevel 1 exit 1
  copy target\generated-sources\license\THIRD-PARTY.txt "%RECIPE_DIR%"\THIRD-PARTY.txt > nul

cd "%SRC_DIR%"\leiningen-src
  echo "Uberjar ...
  call bin\lein uberjar
  if errorlevel 1 exit 1
  echo "Update standalone jar ...
  install -m644 target\leiningen-"%PKG_VERSION%"-standalone.jar %LIBEXEC_DIR%\leiningen-%PKG_VERSION%-standalone.jar
