@echo off
(
  "%PREFIX%\Scripts\jupyter-nbextension" disable @jupyter_dojo/labextension --sys-prefix
  "%PREFIX%\Scripts\jupyter-nbextension" uninstall @jupyter_dojo/labextension --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1