@echo off
setlocal enabledelayedexpansion

cargo install --no-track --locked --root "%PREFIX%" -p csv-utils
if errorlevel 1 exit /b 1

cargo install --no-track --locked --root "%PREFIX%" -p csv-utils-web
if errorlevel 1 exit /b 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1

del /q "%PREFIX%\.crates.toml" 2>nul
del /q "%PREFIX%\.crates2.json" 2>nul
