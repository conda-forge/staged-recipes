:: https://support.mozilla.org/en-US/kb/deploy-firefox-msi-installers
msiexec.exe /i firefox.msi INSTALL_DIRECTORY_PATH=%LIBRARY_BIN% TASKBAR_SHORTCUT=false DESKTOP_SHORTCUT=false INSTALL_MAINTENANCE_SERVICE=false /quiet || exit 1
