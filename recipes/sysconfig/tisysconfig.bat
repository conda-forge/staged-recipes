@echo off
rem
rem Run the SysConfig command line tool
rem 
rem For help, use -h or --help

set tisysconfig_dir=%CONDA_PREFIX%\Library\lib\tisysconfig\

set NODEFLAGS=
if "%1" == "-g" (
	set NODEFLAGS=--inspect --debug-brk
)

node %NODEFLAGS% %tisysconfig_dir%\cli.js %*
