REM stage 1, library
mkdir _build
cd _build

REM add future installation path to pkgconfig
set PKG_CONFIG_PATH=%PREFIX%\lib\pkgconfig;

cmake -G"NMake Makefiles" -DODE_WITH_DEMOS:BOOL=OFF -DODE_WITH_TESTS:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH="" ..
nmake install DESTDIR=%PREFIX%
cd ..

REM stage 2, bindings
cd bindings
cd python
python setup.py install
REM --root %PREFIX% --prefix ""
