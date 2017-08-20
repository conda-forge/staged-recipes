@echo off
(
  REM Uninstall BeakerX notebook extension
  "%PREFIX%\Scripts\beakerx-install.exe"
) >>"%PREFIX%\.messages.txt" 2>&1
