@echo off

REM Install jupyterlab-omnisci labextension
"%CONDA_PREFIX%\Scripts\jupyter-labextension" uninstall jupyterlab-omnisci @jupyter-widgets/jupyterlab-manager if errorlevel 1 exit 1
