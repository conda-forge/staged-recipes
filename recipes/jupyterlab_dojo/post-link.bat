@echo off
(
  "%PREFIX%\Scripts\jupyter-labextension.exe" enable @jupyter_dojo/labextension --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1