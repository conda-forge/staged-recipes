"%PYTHON%" setup.py build_ext --compiler=msvc --fcompiler=gfortran
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
