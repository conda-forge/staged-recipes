"%PYTHON%" setup.py build --compiler=mingw32
if errorlevel 1 exit 1
"%PYTHON%" setup.py build_ext --compiler=mingw32
if errorlevel 1 exit 1
"%PYTHON%" setup.py install
if errorlevel 1 exit 1

