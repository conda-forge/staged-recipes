copy mpi.f.single mpi.f
copy mpif.h.single mpif.h	

gfortran -g -w -O -Wall -o genesis2 main.f check.f diagno.f esource.f field.f incoherent.f math.f partsim.f pushp.f loadbeam.f loadrad.f magfield.f tdepend.f track.f string.f rpos.f scan.f source.f stepz.f timerec.f initrun.f  input.f output.f mpi.f

copy genesis2 %LIBRARY_PREFIX%	

