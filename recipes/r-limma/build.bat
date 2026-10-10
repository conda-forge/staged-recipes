@echo off
setlocal enabledelayedexpansion

move DESCRIPTION DESCRIPTION.old
findstr /v /b "Priority:" DESCRIPTION.old > DESCRIPTION

R CMD INSTALL --build .
if errorlevel 1 exit /b 1
