#!/bin/bash 
mkdir -p fonts 
for fo in $(ls *.ttf); do cp ${fo} ${PREFIX}/fonts/${fo}; done
