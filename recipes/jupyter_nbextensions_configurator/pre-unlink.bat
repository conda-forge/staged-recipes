"%PREFIX%\Scripts\jupyter_nbextensions_configurator.exe" disable --sys-prefix >> "%PREFIX%/.messages.txt" 2>&1
if errorlevel 1 exit 1
