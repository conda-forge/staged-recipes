#!/bin/bash
python -m pip install . -vv
mkdir -p ${PREFIX}/bin
cp moltemplate/scripts/moltemplate.sh ${PREFIX}/bin
cp moltemplate/scripts/cleanup_moltemplate.sh ${PREFIX}/bin
cp moltemplate/scripts/molc.sh ${PREFIX}/bin
cp moltemplate/scripts/pdb2crds.awk ${PREFIX}/bin
cp moltemplate/scripts/emoltemplate.sh ${PREFIX}/bin
