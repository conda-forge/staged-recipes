if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1

dir couchdb

start "Install Firefox MSI" /wait msiexec.exe /i couchdb\apache-couchdb-%PKG_VERSION%.msi APPLICATIONFOLDER=%LIBRARY_BIN% ADMINUSER=admin ADMINPASSWORD=hunter2 /norestart || exit 1

dir %LIBRARY_BIN%