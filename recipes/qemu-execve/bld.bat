setlocal

echo Building QEMU for win-64...
set "build_dir=%SRC_DIR%\_conda-build-win-64"
set "install_dir=%SRC_DIR%\_conda-install-%qemu_arch%"

call powershell -ExecutionPolicy Bypass -Command "& {& '%RECIPE_DIR%\helpers\_build_qemu.ps1' -build_dir '%build_dir%' -install_dir '%install_dir%' -qemu_args @('--target-list=aarch64-softmmu')}" > build_qemu_output.log 2>&1
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
type build_qemu_output.log
echo Done

endlocal

