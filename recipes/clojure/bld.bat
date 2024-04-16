@echo off
setlocal EnableDelayedExpansion

powershell New-Item -ItemType Directory -Path "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -Force

:: The .zip archive only contains one directory (v1.11.2.1448). Conda-build moves it to the root of the build directory.
powershell Move-Item -Path ClojureTools -Destination %PKG_VERSION%.%PKG_BUILD% -Force

powershell Move-Item -Path %PKG_VERSION%.%PKG_BUILD% -Destination "%PREFIX%\WindowsPowerShell\Modules\ClojureTools" -Force
