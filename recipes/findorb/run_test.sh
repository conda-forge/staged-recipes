#!/bin/bash

set -e

# basic checks -- do the executables exist?
test -x ${CONDA_PREFIX}/bin/fo
test -x ${CONDA_PREFIX}/bin/find_orb

# now pretend this is our HOME directory...
export HOME=$PWD
echo "Home testing hack: HOME=$HOME"

# abort if ~/.find_orb already exists
if [[ -e ~/.find_orb ]]; then
	echo "*** ERROR: $HOME/.find_orb already exists; aborting."
	exit -1
fi

# now try running fo, compare the output to expectations
fo single.psv > fo.out
if ! diff fo.out fo.expected.out; then
	echo "-----------------------------------------------"
	echo "*** ERROR: fo: output differs from expectation."
	exit -1
fi

# and verify that ~/.find_orb has been created
if [[ ! -d ~/.find_orb ]]; then
	echo "-------------------------------------------"
	echo "*** ERROR: $HOME/.find_orb"
	echo "*** should have been created but wasn't"
	exit -1
fi

# clean up
rm -r ~/.find_orb
rm fo.out

# all OK!
echo "Tests passed!"
