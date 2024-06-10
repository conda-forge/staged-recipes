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
  %PREFIX%\Scripts\lein.bat bootstrap
  mvn license:add-third-party -Dlicense.thirdPartyFile=THIRD-PARTY.txt
  cp target\generated-sources\license\THIRD-PARTY.txt "${RECIPE_DIR}"\THIRD-PARTY.txt

cd "%SRC_DIR%"\leiningen-src
  bin\lein uberjar
  install -m644 target\leiningen-"%PKG_VERSION%"-standalone.jar %LIBEXEC_DIR%\leiningen-%PKG_VERSION%-standalone.jar

