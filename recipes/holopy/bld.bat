set CFG=%USERPROFILE%\pydistutils.cfg
echo [config] > "%CFG%"
echo compiler=m2w64-gcc-fortran >> "%CFG%"
echo [build] >> "%CFG%"
echo compiler=m2w64-gcc-fortran >> "%CFG%"
echo [build_ext] >> "%CFG%"
echo compiler=m2w64-gcc-fortran >> "%CFG%"

"%PYTHON%" setup.py install
if errorlevel 1 exit 1
