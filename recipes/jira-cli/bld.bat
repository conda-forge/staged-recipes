@echo off
go build -v -o "%PREFIX%\bin\jira.exe" .\cmd\jira
if errorlevel 1 exit 1
