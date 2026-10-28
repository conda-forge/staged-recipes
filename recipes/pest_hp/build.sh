#!/usr/bin/env bash

# SpeedTest is a unused function that causes a compilation error.
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

# PEST_HP instructions to build the executables call for the "clean" target to
# be run after after each *.mak is used.  The *.mak files should be setup
# differently, but for now, we will just follow the instructions and clean
# after each use.  This means that ip.cpp will be deleted, and it is not
# necessarily created in later *.mak files where it might be needed.  So, we
# will build ip.cpp first (using cmaes_hp.mak) and edit the *.mak files to not
# delete it.  This is a hack, but it works for now.
for f in *.mak; do
    sed 's/\trm -f \*\.cpp//g' "$f" > tmp"$f"
    mv tmp"$f" "$f"
done

# Compile
make -f pest_hp.mak cppp
make -f pest_hp.mak clean
# Used here to build ip.cpp, which is needed for later makefiles.
make -f cmaes_hp.mak cmaes_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pest_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pwhisp_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pcost_hp
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

# Install
rm cppp  # Only needed when building.

mkdir -p "${PREFIX}/bin"
find . -type f ! -name '*.sh' -perm -ugo+x -exec cp \{\} "${PREFIX}/bin/" \;

