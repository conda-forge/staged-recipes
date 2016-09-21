@echo off
(
  "%PREFIX%\Scripts\jupyter-serverextension" disable nbexamples --py --sys-prefix
  "%PREFIX%\Scripts\jupyter-nbextension" disable nbexamples --py --sys-prefix
  "%PREFIX%\Scripts\jupyter-nbextension" install nbexamples --py --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1
