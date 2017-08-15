:: Check where we are.
echo %CONDA_PREFIX%
if errorlevel 1 exit 1

:: Check version via import.
python -c "from __future__ import print_function; import conda; print(conda.__version__)"
if errorlevel 1 exit 1

:: Show where the conda commands are.
where conda
if errorlevel 1 exit 1
where conda-env
if errorlevel 1 exit 1

:: Run some conda commands.
conda --version
if errorlevel 1 exit 1
conda info
if errorlevel 1 exit 1
conda env --help
if errorlevel 1 exit 1
