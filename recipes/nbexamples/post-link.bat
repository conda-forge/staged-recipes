@echo off
(
  "%PREFIX%\Scripts\jupyter-nbextension.exe" install nbexamples --py --sys-prefix
  "%PREFIX%\Scripts\jupyter-nbextension.exe" enable nbexamples --py --sys-prefix
  "%PREFIX%\Scripts\jupyter-serverextension.exe" enable --py nbexamples --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1
