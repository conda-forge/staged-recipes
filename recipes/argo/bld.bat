go env -w GOBIN="%PREFIX%\bin"
if errorlevel 1 exit /b 1

go install -ldflags "-X main.version={{ version }}" .
if errorlevel 1 exit /b 1
