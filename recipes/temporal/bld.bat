set LDFLAGS="%LDFLAGS% -s -w -X github.com/temporalio/cli/temporalcli.Version=%PKG_VERSION%"

go build -ldflags "%LDFLAGS%" -o %PREFIX%/bin/temporal ./cmd/temporal
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

@REM store the license files in a separate directory (ignore errors)
go-licenses save ./cmd/temporal --save_path="%SRC_DIR%/license-files/" || true
