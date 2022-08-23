@echo ON

set "GOBIN=%PREFIX%\bin"

@rem https://github.com/stern/stern/blob/v1.21.0/.goreleaser.yaml#L7-L9
set "LDFLAGS=-X github.com/stern/stern/cmd.version=%PKG_VERSION%-%PKG_BUILDNUM%"

go install -v "-ldflags=%LDFLAGS%" .
if %errorlevel% neq 0 exit /b %errorlevel%

go-licenses save . --save_path=license-files
if not exist license-files\github.com\ (exit /b 2)
