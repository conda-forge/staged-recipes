#!/usr/bin/env bash

echo "#### Simple Sirius version test"
sirius --version

if [[ ${target_platform} =~ linux.* ]] ; then
  echo "#### List ALL libs"
  /sbin/ldconfig -v -N
#  echo "#### List Cbc libs"
#  /sbin/ldconfig -v -N | grep Cbc
#  echo "#### List bzip libs"
#  /sbin/ldconfig -v -N | grep bzip
fi

echo "#### Download test data"
wget https://bio.informatik.uni-jena.de/wp/wp-content/uploads/2021/10/Kaempferol.ms

echo "#### Run SIRIUS ILP solver Task"
sirius -i Kaempferol.ms -o test-out sirius

echo "#### Check SIRIUS ILP solver Task results"
#if [ ! -f "test-out/1_Kaempferol_Kaempferol/trees/C15H10O6_[M+H]+.json" ]; then
if [ ! -f "test-out/1_Kaempferol_Kaempferol/trees" ]; then
  echo Framgentation tree test failed!
  exit 1
fi