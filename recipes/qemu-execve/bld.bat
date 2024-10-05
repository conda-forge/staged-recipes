@echo off

setlocal

powershell -ExecutionPolicy Bypass -File "%RECIPE_DIR%\helpers\_build_qemu.ps1" -build_dir "%SRC_DIR%\_conda-build-%qemu_arch%" -install_dir "%SRC_DIR%\_conda-install-%qemu_arch%"

endlocal

