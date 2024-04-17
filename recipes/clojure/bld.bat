@echo off
setlocal EnableDelayedExpansion

powershell New-Item -ItemType Directory -Path "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -Force

powershell Move-Item -Path %SRC_DIR%\clojure-tools -Destination %PKG_VERSION%.%PKG_BUILD% -Force

powershell Move-Item -Path %PKG_VERSION%.%PKG_BUILD% -Destination "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -Force

mkdir %PREFIX%\Scripts

copy %RECIPE_DIR%\scripts\clojure.bat %PREFIX%\Scripts\clojure.bat
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\clj.bat %PREFIX%\Scripts\clj.bat
if errorlevel 1 exit 1

:: ensure that ClojureTools module is registered
set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.ps1 %ACTIVATE_DIR%\clojure-activate.at
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\activate.ps1 %ACTIVATE_DIR%\clojure-activate.ps1
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.ps1 %DEACTIVATE_DIR%\clojure-activate.bat
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.ps1 %DEACTIVATE_DIR%\clojure-activate.ps1
if errorlevel 1 exit 1

:: Possibly prefer registering the module during activation?
::powershell Register-PSRepository -Name ClojureTools -SourceLocation "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -InstallationPolicy Trusted
