#!/bin/bash
set -e

echo "**************** M I S S 3 D  B U I L D  S T A R T S  H E R E ****************"

cp src/Makefile.inc.gnu64 src/Makefile.inc
sed -i "s#INCL = #INCL = -I$PREFIX/include #g" src/Makefile.inc
sed -i "s#LDFLAGS = #LDFLAGS = -L$PREFIX/lib #g" src/Makefile.inc
sed -i "s#F90FLAGS = #F90FLAGS = -fallow-argument-mismatch $FFLAGS #g" src/Makefile.inc
sed -i "s#-Wl,--whole-archive -lpthread -Wl,--no-whole-archive#-lpthread -lgfortran -lm -ldl -lc#g" src/Makefile.inc
sed -i "s#F90 = gfortran#F90 = $F90#g" src/Makefile.inc
sed -i "s#LD = gfortran#F90 = $F90#g" src/Makefile.inc
sed -i "s#/opt/aster/public/miss3d#$PREFIX/bin#g" ./Makefile

make prefix=$PREFIX/bin
make install

echo "**************** M I S S 3 D  B U I L D  E N D S  H E R E ****************"