REM gcm rg
REM gcm ripgrep
REM conda remove -y ripgrep
ECHO "Renaming rg.exe"
REM move C:\Miniconda\envs\true\Library\bin\rg.exe C:\Miniconda\envs\true\Library\bin\rg-desactivate.exe
dir %PREFIX%\Library\bin\
move %PREFIX%\Library\bin\rg.exe %PREFIX%\Library\bin\rg-desactivate.exe


"%PYTHON%" -m pip install . -vv
if errorlevel 1 exit 1