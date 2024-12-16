:: Windows build script

cd %SRC_DIR%\src\gridmarthe\lecsem

::set FFLAGS=-fdefault-real-8 -O2
set FFLAGS="-std=legacy"
::set AR=llvm-ar :: by default with llvm-flang, meson still seek gnu ar
set AR=llvm-link :: by default with llvm-flang, meson still seek gnu ar
%PYTHON% -m numpy.f2py -c lecsem.f90 edsemigl.f90 scan_grid.f90 -m lecsem --backend=meson --lower
if errorlevel 1 exit 1

cd %SRC_DIR%
%PYTHON% -m pip install --no-deps -vv .
if errorlevel 1 exit 1
