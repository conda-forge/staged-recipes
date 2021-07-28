#!/bin/bash
#
if [[ $# -ne 1 ]]
then
  echo "Generate TOR_ARG_LIST for Autodock constants.h"
  echo ""
  echo "Usage:"
  echo ""
  echo "   ./gen_tor_arg_list.sh <maximum number of torsion angles>"
fi
num=$1
echo -n "#define TOR_ARG_LIST        &sInit.tor[0]"
cnt=1
while [[ $cnt -lt $num ]]
do
  echo -n ", &sInit.tor[$cnt]"
  cnt=$((cnt+1))
done
echo ""
