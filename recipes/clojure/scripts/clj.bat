@echo off
PowerShell.exe -Command "Import-Module ClojureTools; ClojureTools\clj $args" %*
