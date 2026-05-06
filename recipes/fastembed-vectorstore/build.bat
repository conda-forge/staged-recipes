@ECHO ON
setlocal EnableDelayedExpansion

:: Ensure USERPROFILE and LOCALAPPDATA are valid
if not defined USERPROFILE set "USERPROFILE=C:\Users\VssAdministrator"
if not defined LOCALAPPDATA set "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"

:: SHGetKnownFolderPath (used by dirs::cache_dir() in ort-sys) reads from
:: "User Shell Folders" (REG_EXPAND_SZ), not "Shell Folders" (REG_SZ).
:: Write to both to ensure the API succeeds for every Python variant build.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Local AppData" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\AppData\Local" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Local AppData" /t REG_SZ /d "%LOCALAPPDATA%" /f >nul 2>&1

set "PYTHONUTF8=1"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1

python -m pip install . --no-build-isolation -vv
if errorlevel 1 exit /b 1
