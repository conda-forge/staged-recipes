@echo off
:: We redirect stderr & stdout to conda's .messages.txt; for details, see
::     http://conda.pydata.org/docs/building/build-scripts.html
"%PREFIX%\Scripts\jupyter.exe" contrib nbextension install --sys-prefix >> "%PREFIX%/.messages.txt" 2>&1
if errorlevel 1 exit 1
