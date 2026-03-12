#!/usr/bin/env bash

sed '/SpeedTest/d' ip.C > ip.tmp
mv ip.tmp ip.C

make -f pest_hp.mak cppp
make -f pest_hp.mak clean
make -f pest_hp.mak pest_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pwhisp_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pcost_hp
make -f pest_hp.mak clean
make -f cmaes_hp.mak cmaes_hp
make -f pest_hp.mak clean
make -f jactest_hp.mak jactest_hp
make -f pest_hp.mak clean
make -f rsi_hp.mak rsi_hp
make -f pest_hp.mak clean
make -f ensi_hp.mak ensiprep
make -f ensi_hp.mak ensimod
make -f ensi_hp.mak postensiunc
make -f pest_hp.mak clean
make -f agent_hp.mak agent_hp
make -f pest_hp.mak clean

rm cppp  # Only needed to compile.

mkdir -p "${PREFIX}/bin"
find . -type f ! -name '*.sh' -executable -exec cp \{\} "${PREFIX}/bin/" \;

