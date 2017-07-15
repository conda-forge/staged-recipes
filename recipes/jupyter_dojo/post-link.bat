@echo off
(
  "%PREFIX%\Scripts\jupyter-nbextension.exe" enable ipython_unittest --py --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1