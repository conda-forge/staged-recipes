if not exist %LIBRARY_PREFIX% mkdir %LIBRARY_PREFIX% || exit 1

dir couchdb

start "Install CouchDB MSI" /wait msiexec.exe /i couchdb\apache-couchdb-%PKG_VERSION%.msi APPLICATIONFOLDER=%LIBRARY_PREFIX% ADMINUSER=admin ADMINPASSWORD=admin /quiet /norestart /l install.log || exit 1

dir %LIBRARY_PREFIX%

type install.log
