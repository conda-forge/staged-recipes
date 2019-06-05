#!/bin/bash 
mkdir -p ${PREFIX}/fonts
for fo in $(ls *.ttf); do cp ${fo} ${PREFIX}/fonts/${fo}; done
