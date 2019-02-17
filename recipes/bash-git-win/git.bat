@echo off
set "_here=%~dp0"
:: _here == [env_root]\bin\
"%_here:~0,-5%\Library\bash-git\bin\git.exe" %*
