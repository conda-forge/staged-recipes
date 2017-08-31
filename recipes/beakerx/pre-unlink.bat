@echo off
(
  REM Run BeakerX uninstall script
  "%PREFIX%\Scripts\beakerx-install.exe" --disable
  REM Uninstall BeakerX notebook extension
  "%PREFIX%\Scripts\jupyter-nbextension.exe" uninstall beakerx --py --sys-prefix
  REM TODO: Restore original custom CSS and assets to notebook custom directory
) >>"%PREFIX%\.messages.txt" 2>&1
