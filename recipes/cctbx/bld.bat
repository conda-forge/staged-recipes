REM copy bootstrap.py
copy modules\cctbx_project\libtbx\auto_build\bootstrap.py .

REM build
%PYTHON% bootstrap.py build --builder=cctbx --use-conda %PREFIX% --nproc %CPU_COUNT% --config-flags="--no_bin_python"
cd build
call .\bin\libtbx.configure cma_es crys3d fable rstbx spotinder
call .\bin\libtbx.scons -j %CPU_COUNT%
call .\bin\libtbx.scons -j %CPU_COUNT%
cd ..

REM remove dxtbx and cbflib
del /S /Q .\build\*dxtbx*
del /S /Q .\build\*cbflib*
del /S /Q .\lib\*dxtbx*
del /S /Q .\lib\*cbflib*
del /S /Q .\modules\*dxtbx*
del /S /Q .\modules\*cbflib*
call .\build\bin\libtbx.python %RECIPE_DIR%\clean_env.py

REM remove intermediate objects in build directory
cd build
del /S /Q *.obj
cd ..

REM copy files in build
SET EXTRA_CCTBX_DIR=%LIBRARY_PREFIX%\share\cctbx
mkdir  %EXTRA_CCTBX_DIR%
SET CCTBX_CONDA_BUILD=.\modules\cctbx_project\libtbx\auto_build\conda_build
call .\build\bin\libtbx.python %CCTBX_CONDA_BUILD%\install_build.py --prefix %LIBRARY_PREFIX% --sp-dir %SP_DIR% --ext-dir %PREFIX%\lib

REM copy libtbx_env and update dispatchers
echo Copying libtbx_env
call .\build\bin\libtbx.python %CCTBX_CONDA_BUILD%\update_libtbx_env.py
%PYTHON% %CCTBX_CONDA_BUILD%\update_libtbx_env.py
