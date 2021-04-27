@echo off
(
  "%PREFIX%\Scripts\jupyter-nbextension.exe" install --sys-prefix --py rsconnect_jupyter
  "%PREFIX%\Scripts\jupyter-nbextension.exe" enable --sys-prefix --py rsconnect_jupyter
  "%PREFIX%\Scripts\jupyter-serverextension.exe" enable --sys-prefix --py rsconnect_jupyter
) >>"%PREFIX%\.messages.txt" 2>&1