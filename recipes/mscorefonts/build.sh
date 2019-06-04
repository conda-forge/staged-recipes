#!/bin/bash
ls -al
for ar in $(ls *.EXE); do cabextract $ar; done 
cp *.TTF ${SP_DIR}/matplotlib/mpl-data/fonts/ttf
