REM gcm rg
REM gcm ripgrep
REM conda remove -y ripgrep
ECHO "Renaming rg.exe"
move C:\Miniconda\envs\true\Library\bin\rg.exe C:\Miniconda\envs\true\Library\bin\rg-desactivate.exe
"%PYTHON%" -m pip install . -vv
if errorlevel 1 exit 1