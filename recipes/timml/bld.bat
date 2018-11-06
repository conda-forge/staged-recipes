"%PYTHON%" setup.py build_ext --inplace --compiler=mingw32 --fcompiler=gfortran
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
