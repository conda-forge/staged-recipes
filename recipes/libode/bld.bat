mkdir _build
cd _build
cmake -G"NMake Makefiles" -DODE_WITH_DEMOS:BOOL=OFF -DODE_WITH_TESTS:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH="" ..
nmake install
