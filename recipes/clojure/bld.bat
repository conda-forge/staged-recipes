@echo off
setlocal EnableDelayedExpansion

powershell New-Item -ItemType Directory -Path "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -Force

powershell Move-Item -Path %SRC_DIR%\clojure-tools\ClojureTools -Destination %PKG_VERSION%.%PKG_BUILD% -Force

powershell Move-Item -Path %PKG_VERSION%.%PKG_BUILD% -Destination "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -Force
