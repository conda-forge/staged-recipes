:: Windows build script

cd %SRC_DIR%\src\gridmarthe\lecsem

:: %PYTHON% setup.py build_ext --inplace --compiler=mingw64 --fcompiler=gnu95 -f
%PYTHON% -m numpy.f2py -c lecsem.f90 edsemigl.f90 scan_grid.f90 -m lecsem --backend=meson --lower
if errorlevel 1 exit 1

cd %SRC_DIR%
%PYTHON% -m pip install --no-deps -vv .
if errorlevel 1 exit 1
