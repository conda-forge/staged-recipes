REM gcm rg
REM gcm ripgrep
REM conda remove -y ripgrep
mv C:\Miniconda\envs\true\Library\bin\rg.exe C:\Miniconda\envs\true\Library\bin\rg-desactivate.exe
"%PYTHON%" -m pip install . -vv
REM "%PYTHON%" setup.py install
if errorlevel 1 exit 1