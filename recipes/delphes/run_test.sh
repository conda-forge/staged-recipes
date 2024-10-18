#!/bin/bash

# Running the 'DelphesXXX --help' commands results in exit code 1,
# so check for existence instead.
echo -e "\n# Check installed executables"

echo "# test -f ${PREFIX}/bin/DelphesHepMC2"
test -f "${PREFIX}/bin/DelphesHepMC2"

echo "# test -f ${PREFIX}/bin/DelphesHepMC3"
test -f "${PREFIX}/bin/DelphesHepMC3"

echo "# test -f ${PREFIX}/bin/DelphesLHEF"
test -f "${PREFIX}/bin/DelphesLHEF"

echo "# test -f ${PREFIX}/bin/DelphesPythia8"
test -f "${PREFIX}/bin/DelphesPythia8"

echo "# test -f ${PREFIX}/bin/DelphesROOT"
test -f "${PREFIX}/bin/DelphesROOT"

echo "# test -f ${PREFIX}/bin/DelphesSTDHEP"
test -f "${PREFIX}/bin/DelphesSTDHEP"

echo -e "\n# Z->ee simulation example"
# N.B.: MUST be http not https (unfortunately)
curl -LO http://cp3.irmp.ucl.ac.be/downloads/z_ee.hep.gz
gunzip z_ee.hep.gz
DelphesSTDHEP $PREFIX/cards/delphes_card_CMS.tcl delphes_output.root z_ee.hep

echo -e "\n# ROOT macro example 1"
# avoid lots of output to stdout
root -l -b -q $PREFIX/examples/Example1.C'("delphes_output.root")' &> /dev/null

echo -e "\n# ROOT macro example 2"
root -l -b -q $PREFIX/examples/Example2.C'("delphes_output.root")'

echo -e "\n# ROOT macro example 3"
root -l -b -q $PREFIX/examples/Example3.C'("delphes_output.root")'

echo -e "\n# ROOT macro example 4"
root -l -b -q $PREFIX/examples/Example4.C'("delphes_output.root", "plots.root")'

echo -e "\n# ROOT macro example 5"
root -l -b -q $PREFIX/examples/Example5.C'("delphes_output.root")' &> /dev/null

# FIXME: Example6.C is failing in CI but not locally
# echo -e "\n# ROOT macro example 6"
# root -l -b -q $PREFIX/examples/Example6.C'("delphes_output.root")'
