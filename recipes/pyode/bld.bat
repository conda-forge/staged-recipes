REM part 1, the library
mkdir _build
cd _build
cmake -G"NMake Makefiles" -DODE_WITH_DEMOS:BOOL=OFF -DODE_WITH_TESTS:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH="" ..
nmake install
cd ..

REM part 2, ode python bindings
cd bindings/python
python setup.py install --root %PREFIX% --prefix ""
