@ECHO ON
setlocal EnableDelayedExpansion

:: Ensure LOCALAPPDATA is defined and the directory exists
if not defined LOCALAPPDATA set "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"

:: Write the Shell Folders registry key so SHGetKnownFolderPath (called by
:: ort-sys via dirs::cache_dir()) succeeds for every Python variant in the
:: same CI job. Without this, the key can be absent for non-first variants.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Local AppData" /t REG_SZ /d "%LOCALAPPDATA%" /f >nul 2>&1

:: Use dynamic loading so ort is loaded at runtime and no onnxruntime.lib is
:: needed at link time (the conda onnxruntime package ships only the DLL).
set "ORT_PREFER_DYNAMIC_LINK=1"

set "PYTHONUTF8=1"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1

python -m pip install . --no-build-isolation -vv
if errorlevel 1 exit /b 1
