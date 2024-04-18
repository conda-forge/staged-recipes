@set "PATH=%CONDA_PREFIX%\Scripts;%PATH%"

@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0\clojure-activate.ps1"
