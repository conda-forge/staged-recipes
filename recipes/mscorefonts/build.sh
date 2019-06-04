#!/bin/bash
for ar in $(ls *.exe); do cabextract $ar; done 
for fo in $(ls *.ttf *.TTF); do cp ${fo} ${SP_DIR}/matplotlib/mpl-data/fonts/ttf/$(echo "${fo}" | awk '{print tolower($0)}'); done
