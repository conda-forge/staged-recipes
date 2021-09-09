@echo off
(
  "%PREFIX%\Scripts\jupyter-serverextension" disable --sys-prefix --py rsconnect_jupyter
  "%PREFIX%\Scripts\jupyter-nbextension" uninstall --sys-prefix --py rsconnect_jupyter
) >>"%PREFIX%\.messages.txt" 2>&1