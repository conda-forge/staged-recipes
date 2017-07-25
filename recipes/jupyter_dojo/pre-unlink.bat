@echo off
(
  "%PREFIX%\Scripts\jupyter-nbextension" disable ipython_unittest --py --sys-prefix
  "%PREFIX%\Scripts\jupyter-nbextension" uninstall ipython_unittest --py --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1