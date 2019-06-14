@echo off

REM Install jupyterlab-omnisci labextension
"%PREFIX%\Scripts\jupyter-labextension" install jupyterlab-omnisci @jupyter-widgets/jupyterlab-manager > NUL 2>&1 && if errorlevel 1 exit 1
