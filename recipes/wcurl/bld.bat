@echo off

mkdir "%PREFIX%\bin"
copy "%SRC_DIR%\wcurl" "%PREFIX%\bin\wcurl" >nul
