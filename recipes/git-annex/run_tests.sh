#!/bin/sh

set -e -o pipefail -x


git init
echo running git annex
git annex init
echo git annex init returned $?


if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		echo LDD IS
		ldd ${PREFIX}/bin/git-annex
		ls -l /staged-recipes/build_artefacts/linux-64/git-annex-6.20171003-pl5.22.2.1_0.tar.bz2
		anaconda login --username notestaff_tmp --password w52sN6wEKe7x5aBV
		anaconda upload /staged-recipes/build_artefacts/linux-64/git-annex-6.20171003-pl5.22.2.1_0.tar.bz2
fi
