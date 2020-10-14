copy mpi.f.single mpi.f
copy mpif.h.single mpif.h	

set COMPILER=gfortran
make

copy genesis2 %LIBRARY_PREFIX%	

