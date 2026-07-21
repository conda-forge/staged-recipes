@echo off
REM Remove any pre-existing license-files directory to avoid conflicts.
if exist license-files rmdir /s /q license-files

REM Save licenses of dependencies, ignoring go-localereader (this creates the license-files directory)
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader || goto :error

REM Download the upstream license for go-localereader into the license-files directory.
curl -L https://raw.githubusercontent.com/mattn/go-localereader/master/LICENSE -o license-files\go-localereader.LICENSE || goto :error

REM Build the Go binary for 'walk'
go build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\walk.exe" -ldflags="-s -w -X main.Version=%PKG_VERSION%" || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b 1
