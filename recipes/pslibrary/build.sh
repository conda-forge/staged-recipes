#!/bin/bash
./make_all_ps
mkdir -p ${PREFIX}/share/pslibrary
find . -name '*.UPF' -exec cp --parents \{\} ${PREFIX}/share/pslibrary \;
find ${PREFIX}/share/pslibrary -name '*.UPF'
