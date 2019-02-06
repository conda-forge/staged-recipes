@echo off
set "script_dir=%~dp0"
REM   == envroot\Scripts\
set "mathjax=%script_dir:~0,-9%\Library\lib\mathjax\MathJax.js"
if not exist "%mathjax%" exit 1
set "script=%script_dir%mathjax-path"
echo @echo %mathjax% > "%script%.bat"
echo #!/bin/bash > "%script%"
echo cygpath '%mathjax%' >> "%script%"
