set CONDA_INCLUDE=%LIBRARY_PREFIX%\include
mkdir %CONDA_INCLUDE%
copy "lmdb++.h" "%CONDA_INCLUDE%\"