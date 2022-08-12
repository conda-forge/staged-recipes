md build
go build -o build ".\cmd\toml-test"
if errorlevel 1 exit 1

md %LIBRARY_BIN% %LIBRARY_PREFIX%\share\toml-test\tests
copy build\toml-test.exe %LIBRARY_BIN%\toml-test.exe
xcopy tests %LIBRARY_PREFIX%\share\toml-test\tests\ /S /E /K /F /C /I /Y
