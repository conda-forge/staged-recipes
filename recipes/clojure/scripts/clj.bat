@echo on
set args=%*

@echo off
PowerShell.exe -Command "Import-Module ClojureTools; ClojureTools\clj $args"
