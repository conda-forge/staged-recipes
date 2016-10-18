set CFG=%USERPROFILE%\pydistutils.cfg
echo [config] > "%CFG%"
echo compiler=mingw32 >> "%CFG%"
echo [build] >> "%CFG%"
echo compiler=mingw32 >> "%CFG%"
echo [build_ext] >> "%CFG%"
echo compiler=mingw32 >> "%CFG%"

"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
