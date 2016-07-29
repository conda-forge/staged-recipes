@echo off
(
  "%PREFIX%\Scripts\jupyter-nbextension" disable nb_conda --py --sys-prefix
  "%PREFIX%\Scripts\jupyter-serverextension" disable nb_conda --py --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1
