rem  Only appveyor has these tools

set

bash configure  --disable-dependency-tracking --disable-openmp CFLAGS=-fpermissive PREFIX=%PREFIX%  

mingw32-make -j2
mingw32-make install

cd python
mingw32-make pip
set  plumed_default_kernel=%PREFIX%/lib/libplumedKernel%SHLIB_EXT%
%PYTHON% -m pip install .
