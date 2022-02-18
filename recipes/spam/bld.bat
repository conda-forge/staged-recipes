set EIGEN_INCLUDE_DIR=%PREFIX%\Library\include\eigen3
set CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1

"%PYTHON%" setup.py install
