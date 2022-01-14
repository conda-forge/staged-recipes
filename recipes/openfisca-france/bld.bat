gcm rg
gcm ripgrep
REM conda remove -y ripgrep
"%PYTHON%" -m pip install . -vv
REM "%PYTHON%" setup.py install
if errorlevel 1 exit 1