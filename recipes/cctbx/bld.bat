REM copy bootstrap.py
copy modules\cctbx_project\libtbx\auto_build\bootstrap.py .

REM copy LICENSE.txt to root
copy modules\cctbx_project\LICENSE.txt .

REM remove extra source code
rmdir /S /Q .\modules\boost
rmdir /S /Q .\modules\eigen
rmdir /S /Q .\modules\scons
del /Q .\modules\cctbx_project\libtbx\command_line\pytest_launcher.py

REM build
%PYTHON% bootstrap.py build --builder=cctbx --use-conda %PREFIX% --nproc %CPU_COUNT% --config-flags="--enable_cxx11" --config-flags="--no_bin_python" --config-flags="--skip_phenix_dispatchers"
cd build
call .\bin\libtbx.configure cma_es crys3d fable rstbx spotinder
call .\bin\libtbx.scons -j %CPU_COUNT%
call .\bin\libtbx.scons -j %CPU_COUNT%
cd ..

REM remove dxtbx and cbflib
del /S /Q .\build\*dxtbx*
del /S /Q .\build\*cbflib*
del /S /Q .\build\lib\dxtbx*
del /S /Q .\build\lib\cbflib*
rmdir /S /Q .\modules\dxtbx
rmdir /S /Q .\modules\cbflib
call .\build\bin\libtbx.python %RECIPE_DIR%\clean_env.py

REM remove extra source files (C, C++, Fortran, CUDA)
cd build
del /S /Q *.c
del /S /Q *.cpp
del /S /Q *.cu
del /S /Q *.f
cd ..\modules
del /S /Q *.c
del /S /Q *.cpp
del /S /Q *.cu
del /S /Q *.f
cd ..

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

REM remove extra copies of dispatchers
attrib +H %LIBRARY_BIN%\libtbx.show_build_path.bat
attrib +H %LIBRARY_BIN%\libtbx.show_dist_paths.bat
del /Q %LIBRARY_BIN%\*show_build_path.bat
del /Q %LIBRARY_BIN%\*show_dist_paths.bat
attrib -H %LIBRARY_BIN%\libtbx.show_build_path.bat
attrib -H %LIBRARY_BIN%\libtbx.show_dist_paths.bat
