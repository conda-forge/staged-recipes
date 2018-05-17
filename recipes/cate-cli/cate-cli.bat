@echo off

set CATE_BIN=%~dp0

rem Make CATE_HOME=%CATE_BIN%\.. an absolute path:
pushd .
cd /D "%CATE_BIN%\.."
set CATE_HOME=%CD%
popd

call "%CATE_BIN%\activate.bat" "%CATE_HOME%"
if errorlevel 1 exit 1

if "%*" == "" (
  goto INTERACTIVE
) else (
  goto DELEGATE
)

:INTERACTIVE
prompt $G$S
echo.
@echo ESA CCI Toolbox (CLI) command-line interface. Type "cate -h" to get help.
echo.

cmd /K ""
exit 0

:DELEGATE
%*
exit 0

