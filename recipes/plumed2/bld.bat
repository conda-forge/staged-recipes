rem  Only appveyor has these tools

set

bash configure CFLAGS=-fpermissive --disable-dependency-tracking PREFIX=%PREFIX%

mingw32-make -j2
mingw32-make install

cd python
make pip
set  plumed_default_kernel=%PREFIX%/lib/libplumedKernel%SHLIB_EXT%
%PYTHON% -m pip install .
