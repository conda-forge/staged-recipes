"%PREFIX%\Scripts\jupyter_nbextensions_configurator.exe" enable --sys-prefix >> "%PREFIX%/.messages.txt" 2>&1
if errorlevel 1 exit 1
