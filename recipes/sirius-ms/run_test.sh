#!/usr/bin/env sh

sirius --version

wget https://bio.informatik.uni-jena.de/wp/wp-content/uploads/2021/10/Kaempferol.ms

sirius -i Kaempferol.ms -o test-out sirius

#if [ ! -f "test-out/1_Kaempferol_Kaempferol/trees/C15H10O6_[M+H]+.json" ]; then
if [ ! -f "test-out/1_Kaempferol_Kaempferol/trees" ]; then
  echo Framgentation tree test failed!
  exit 1
fi