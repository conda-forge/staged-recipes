@echo off
:: We redirect stderr & stdout to conda's .messages.txt; for details, see
::     http://conda.pydata.org/docs/building/build-scripts.html
(
  "%PREFIX%\Scripts\python.exe" -c "import logging; from jupyter_contrib_core.notebook_compat.nbextensions import uninstall_nbextension_python; uninstall_nbextension_python('jupyter_latex_envs', sys_prefix=True, logger=logging.getLogger())"
) >>"%PREFIX%\.messages.txt" 2>&1
