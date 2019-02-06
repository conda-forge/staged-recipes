@echo off
set "script_dir=%~dp0"
set "script=%script_dir%mathjax-path"
del /q "%script%.bat" "%script%" || exit 1
