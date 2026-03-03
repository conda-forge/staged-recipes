@echo on

cd src
if errorlevel 1 exit /b 1

:: Build frontend
cd frontend
if errorlevel 1 exit /b 1
call npm install
if errorlevel 1 exit /b 1
call npm run build
if errorlevel 1 exit /b 1
cd ..

:: Copy frontend dist to web embed directory
if exist internal\web\dist rmdir /s /q internal\web\dist
xcopy /e /i /y frontend\dist internal\web\dist
if errorlevel 1 exit /b 1

:: Install wails CLI
go install github.com/wailsapp/wails/v2/cmd/wails@latest
if errorlevel 1 exit /b 1

:: Collect Go dependency licenses
go-licenses save . --save_path ../library_licenses
if errorlevel 1 exit /b 1

:: Build desktop app
wails build -ldflags "-s -w -X main.Version=%PKG_VERSION%"
if errorlevel 1 exit /b 1

copy build\bin\Nebi.exe %LIBRARY_BIN%\nebi-desktop.exe
if errorlevel 1 exit /b 1

:: Install menuinst menu config and icons
mkdir %PREFIX%\Menu
if errorlevel 1 exit /b 1

powershell -Command "(Get-Content '%RECIPE_DIR%\nebi-desktop-menu.json') -replace '__PKG_VERSION__', '%PKG_VERSION%' | Set-Content '%PREFIX%\Menu\nebi-desktop-menu.json'"
if errorlevel 1 exit /b 1

copy %RECIPE_DIR%\nebi.ico %PREFIX%\Menu\nebi.ico
if errorlevel 1 exit /b 1
