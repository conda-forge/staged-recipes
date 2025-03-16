#!/usr/bin/env bash

set -xe

mkdir -p ${PREFIX}/{bin, lib, include} 

export C_INCLUDE_PATH="${PREFIX}/include"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CEXE="$CC -I. $CFLAGS -L. $LDFLAGS"

cd src
make -f other_builds/Makefile.linux_universal

for binary in 1deval 1dmatcalc 1dplot 1dtranspose 24swap 2dImReg 2swap 3dANOVA 3dANOVA2 \
    3dANOVA3 3dDeconvolve 3dFriedman 3dIntracranial 3dKruskalWallis 3dMannWhitney 3dNLfim \
    3dNotes 3dROIstats 3dRegAna 3dStatClust 3dTSgen 3dTcat 3dTsmooth 3dTstat 3dWilcoxon \
    3daxialize 3dbucket 3dcalc 3dclust 3dfractionize 3dhistog 3dinfo 3dmaskave 3dmaskdump \
    3dmerge 3dnewid 3dnvals 3dpc 3drefit 3drotate 3dvolreg 4swap RSFgen \
    adwarp afni byteorder ccalc cdf cjpeg count count_afni djpeg fim2 float_scan \
    from3d imand imaver imcalc imdump immask imreg imrotate imstack imstat imupsam \
    nsize plugout_ijk plugout_tt plugout_tta sfim tfim to3d waver; do
    
    install -v -m 0755 ${binary} ${PREFIX}/bin
done

for header in coxplot.h niml.h; do
    install -v -m 0644 ${header} ${PREFIX}/include
done

for library in libmri.so libf2c.so; do
    install -v -m 0644 ${library} ${PREFIX}/lib
done