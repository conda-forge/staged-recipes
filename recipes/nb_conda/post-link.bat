@echo off
(
  "%PREFIX%\Scripts\jupyter-nbextension.exe" enable nb_conda --py --sys-prefix
  "%PREFIX%\Scripts\jupyter-serverextension.exe" enable --py nb_conda --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1
