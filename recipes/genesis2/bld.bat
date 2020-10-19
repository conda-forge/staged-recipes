copy mpi.f.single mpi.f
copy mpif.h.single mpif.h

if errorlevel 1 exit 1

x86_64-w64-mingw32-gfortran -static -w -O -Wall -o genesis2 main.f check.f diagno.f esource.f field.f incoherent.f math.f partsim.f pushp.f loadbeam.f loadrad.f magfield.f tdepend.f track.f string.f rpos.f scan.f source.f stepz.f timerec.f initrun.f  input.f output.f mpi.f > output.txt 2>&1

if errorlevel 1 exit 1

copy genesis2.exe %LIBRARY_BIN%

if errorlevel 1 exit 1
exit 0
