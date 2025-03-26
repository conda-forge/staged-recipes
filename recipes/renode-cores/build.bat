@echo on
:: powershell -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "%RECIPE_DIR%\helpers\renode_build_with_cmake.ps1"
powershell -NoLogo -NonInteractive -ExecutionPolicy Bypass -Command "& { try { . '%RECIPE_DIR%\helpers\renode_build_with_cmake.ps1'; exit $LASTEXITCODE } catch { Write-Error $_; exit 1 } }"
if %errorlevel% neq 0 exit /b  %errorlevel%
