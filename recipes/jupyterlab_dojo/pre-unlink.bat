@echo off
(
  "%PREFIX%\Scripts\jupyter-nbextension" disable @jupyter_dojo/labextension
  "%PREFIX%\Scripts\jupyter-nbextension" uninstall @jupyter_dojo/labextension
) >>"%PREFIX%\.messages.txt" 2>&1