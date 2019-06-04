#!/bin/bash
for ar in $(ls *.exe); do cabextract $ar; done 
ls -al
cp *.ttf ${SP_DIR}/matplotlib/mpl-data/fonts/ttf
