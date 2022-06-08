if not exist %LIBRARY_PREFIX%\couchdb mkdir %LIBRARY_PREFIX%\couchdb || exit 1

start "Install CouchDB MSI" /wait msiexec.exe /i apache-couchdb-%PKG_VERSION%.msi APPLICATIONFOLDER=%LIBRARY_PREFIX%\couchdb ADMINUSER=admin ADMINPASSWORD=admin /quiet /norestart /l install.log || exit 1

type install.log

if not exist %LIBRARY_PREFIX%\bin mkdir %LIBRARY_PREFIX%\bin || exit 1
@echo off
echo %LIBRARY_PREFIX%\couchdb\bin\couchdb %%* > %LIBRARY_PREFIX%\bin\couchdb.cmd
echo %LIBRARY_PREFIX%\couchdb\bin\couchjs %%* > %LIBRARY_PREFIX%\bin\couchjs.cmd
