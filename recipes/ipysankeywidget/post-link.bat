@echo off

(
  "%PREFIX%\Scripts\jupyter-nbextension.exe" enable ipysankeywidget --py --sys-prefix
) >>"%PREFIX%\.messages.txt" 2>&1
