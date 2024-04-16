@echo off
setlocal EnableDelayedExpansion

echo Installing PowerShell module
powershell -Command "Expand-Archive clojure-tools\clojure-tools.zip -DestinationPath '%PREFIX%'"
