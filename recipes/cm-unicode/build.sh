#!/bin/bash 
for fo in $(ls *.ttf); do cp ${fo} ${SP_DIR}/matplotlib/mpl-data/fonts/ttf/${fo}; done
