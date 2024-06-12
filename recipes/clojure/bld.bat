@echo off
setlocal EnableDelayedExpansion

powershell New-Item -ItemType Directory -Path "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -Force

powershell Move-Item -Path %SRC_DIR%\win-clojure-tools -Destination %PKG_VERSION% -Force

powershell Move-Item -Path %PKG_VERSION% -Destination "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -Force

mkdir %PREFIX%\Scripts

copy %RECIPE_DIR%\scripts\clojure.bat %PREFIX%\Scripts\clojure.bat > nul
if errorlevel 1 exit 1
echo copied :PREFIX:\Scripts\clojure.bat

copy %RECIPE_DIR%\scripts\clj.bat %PREFIX%\Scripts\clj.bat > nul
if errorlevel 1 exit 1
echo copied :PREFIX:\Scripts\clj.bat

:: ensure that ClojureTools module is registered
set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\clojure-activate.bat > nul
if errorlevel 1 exit 1
echo copied :ACTIVATE_DIR:\clojure-activate.bat

copy %RECIPE_DIR%\scripts\activate.ps1 %ACTIVATE_DIR%\clojure-activate.ps1 > nul
if errorlevel 1 exit 1
echo copied :ACTIVATE_DIR:\clojure-activate.ps1

copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\clojure-deactivate.bat > nul
if errorlevel 1 exit 1
echo copied :DEACTIVATE_DIR:\clojure-deactivate.bat

copy %RECIPE_DIR%\scripts\deactivate.ps1 %DEACTIVATE_DIR%\clojure-deactivate.ps1 > nul
if errorlevel 1 exit 1
echo copied :DEACTIVATE_DIR:\clojure-deactivate.ps1

:: Licenses
cd %SRC_DIR%\clojure-src
  call mvn license:add-third-party -DlicenseFile=THIRD-PARTY.txt > nul

copy %SRC_DIR%\clojure-src\epl-v10.html %RECIPE_DIR%\epl-v10.html > nul
copy %SRC_DIR%\clojure-src\target\generated-sources\license\THIRD-PARTY.txt %RECIPE_DIR%\THIRD-PARTY.txt > nul

:: Possibly prefer registering the module during activation?
::powershell Register-PSRepository -Name ClojureTools -SourceLocation "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -InstallationPolicy Trusted
