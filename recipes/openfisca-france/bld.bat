ECHO "Renaming rg.exe, see https://github.com/conda-forge/staged-recipes/issues/17519"
move C:\Miniconda\Library\bin\rg.exe C:\Miniconda\Library\bin\rg-desactivate.exe
"%PYTHON%" -m pip install . -vv
if errorlevel 1 exit 1