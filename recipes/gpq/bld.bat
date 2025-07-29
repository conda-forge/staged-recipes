cd gpq-%PKG_VERSION%
go build -v -o "%LIBRARY_BIN%\gpq.exe" ./cmd/gpq
if errorlevel 1 exit 1

