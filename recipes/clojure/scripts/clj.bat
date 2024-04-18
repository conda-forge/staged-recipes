@echo on
set args=%*

@echo off
powershell -Command Import-Module ClojureTools
powershell -Command "& ClojureTools\clj '%*'"
