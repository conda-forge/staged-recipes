sed "s#@cdat_EXTERNALS@#${PREFIX}#g;" Makefile.gfortran.in > Makefile.gfortran
make  -f Makefile.gfortran
make -f Makefile.gfortran install
