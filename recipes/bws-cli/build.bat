@echo off
cargo install --no-track --root "%PREFIX%" --path crates\bws
if %ERRORLEVEL% neq 0 exit /b 1
