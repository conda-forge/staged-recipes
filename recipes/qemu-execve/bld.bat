setlocal

echo Building QEMU for win-64...
set "build_dir=%SRC_DIR%\_conda-build-win-64"
set "install_dir=%SRC_DIR%\_conda-install-%qemu_arch%"

call powershell -ExecutionPolicy Bypass -File "%RECIPE_DIR%\helpers\_build_qemu.ps1" -Command "Build-WinQemu -build_dir '%build_dir%' -install_dir '%install_dir%' -qemu_args @('--target-list=aarch64-softmmu')"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
echo Done

endlocal

