:: gfortran env is set MINGW_PREFIX
:: conda root path is set CONDA_PREFIX
set path=%path%;%MINGW_PREFIX%\mingw64\bin;%CONDA_PREFIX%\Scripts
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
