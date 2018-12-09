rem  Only appveyor has these tools

set

rem bash configure  --disable-dependency-tracking --disable-openmp CFLAGS=-fpermissive PREFIX=%PREFIX%  
bash configure  --disable-dependency-tracking --disable-openmp --disable-shared CFLAGS=-fpermissive LDFLAGS="-static -s" PREFIX=%PREFIX%  


mingw32-make -j2
mingw32-make install

rem cd python
rem mingw32-make pip
rem set  plumed_default_kernel=%PREFIX%/lib/libplumedKernel%SHLIB_EXT%
rem %PYTHON% -m pip install .
