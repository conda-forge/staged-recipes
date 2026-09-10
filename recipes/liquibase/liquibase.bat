@echo off
call "%~dp0..\share\liquibase\liquibase.bat" %*
exit /b %ERRORLEVEL%