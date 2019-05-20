@echo off

(
  "%PREFIX%\Scripts\jupyter-nbextension.exe" uninstall ipysankeywidget --py --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1