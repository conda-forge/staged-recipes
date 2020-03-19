REM reorganize directories
call %RECIPE_DIR%\fix_directories.bat

REM build
python bootstrap.py build --builder=cctbxlite --use-conda %PREFIX% --nproc %CPU_COUNT% --config-flags="--no_bin_python"

REM copy files in build
SET CCTBX_CONDA_BUILD=.\modules\cctbx_project\libtbx\auto_build\conda_build
call .\build\bin\libtbx.python %CCTBX_CONDA_BUILD%\install_build.py --prefix %LIBRARY_PREFIX% --sp-dir %SP_DIR% --ext-dir %PREFIX%\lib

REM copy libtbx_env and fixing script
echo Copying libtbx_env
call .\build\bin\libtbx.python %CCTBX_CONDA_BUILD%\update_libtbx_env.py
SET EXTRA_CCTBX_DIR=%LIBRARY_PREFIX%\share\cctbx
mkdir  %EXTRA_CCTBX_DIR%
copy %CCTBX_CONDA_BUILD%\update_libtbx_env.py %EXTRA_CCTBX_DIR%\update_libtbx_env.py
