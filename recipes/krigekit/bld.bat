python build_lib.py --compiler gfortran
if errorlevel 1 exit 1

pip install . --no-deps --no-build-isolation -v
if errorlevel 1 exit 1
