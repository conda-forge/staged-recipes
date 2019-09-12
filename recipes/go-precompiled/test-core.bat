setlocal enabledelayedexpansion

rem Environment checks
go env
cmd /c if x%GOROOT% NEQ x%CONDA_PREFIX%\go exit 1
if errorlevel 1 exit 1

rem List go tool
go tool
if errorlevel 1 exit 1

rem Run go's built-in test
go tool dist test -k -v -no-rebuild
if errorlevel 1 exit 1

