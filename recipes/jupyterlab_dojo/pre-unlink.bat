@echo off
(
  "%PREFIX%\Scripts\jupyter-labextension" disable @jupyter_dojo/labextension
  "%PREFIX%\Scripts\jupyter-labextension" uninstall @jupyter_dojo/labextension
) >>"%PREFIX%\.messages.txt" 2>&1