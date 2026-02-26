@echo on

cd src
if errorlevel 1 exit /b 1

:: Build frontend
cd frontend && npm install && npm run build && cd ..
if errorlevel 1 exit /b 1

:: Copy frontend dist to web embed directory
if exist internal\web\dist rmdir /s /q internal\web\dist
xcopy /e /i /y frontend\dist internal\web\dist
if errorlevel 1 exit /b 1

:: Collect Go dependency licenses
go-licenses save ./cmd/nebi --save_path ../library_licenses
if errorlevel 1 exit /b 1

:: Build the binary
go build -v -o "%LIBRARY_BIN%\nebi.exe" -ldflags="-s -w -X main.Version=%PKG_VERSION%" ./cmd/nebi
if errorlevel 1 exit /b 1
