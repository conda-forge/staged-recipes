#!/usr/bin/env bash

# Don't use 'sed -i' because it is not portable across linux and OSX. Instead,
# use a temporary file and move it back to the original file.

sed '/SpeedTest/d' ip.C > tmpip.C
mv tmpip.C ip.C

# OSX does not support static linking, so remove the -static flag from the
# makefiles.
if [[ "$OSTYPE" == "darwin"* ]]; then
    for f in *.mak; do
        sed 's/-static//g' "$f" > tmp"$f"
        mv tmp"$f" "$f"
    done
fi

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
find . -type f ! -name '*.sh' -perm -ugo+x -exec cp \{\} "${PREFIX}/bin/" \;

