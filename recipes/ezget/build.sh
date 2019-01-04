MAKEFILE=ezget_Makefile.gfortran

sed "s#@cdat_EXTERNALS@#${PREFIX}#g;" ${MAKEFILE}.in > ${MAKEFILE}
make  -f ${MAKEFILE}
make -f ${MAKEFILE} install
