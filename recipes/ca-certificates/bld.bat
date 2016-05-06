:: Create the directory to hold the certificates.
if not exist %LIBRARY_PREFIX%\ssl mkdir %LIBRARY_PREFIX%\ssl
if errorlevel 1 exit 1

:: Copy the certificates from certifi.
copy /y %SP_DIR%\certifi\cacert.pem %LIBRARY_PREFIX%\ssl
if errorlevel 1 exit 1
copy /y %LIBRARY_PREFIX%\ssl\cacert.pem %LIBRARY_PREFIX%\ssl\cert.pem
if errorlevel 1 exit 1
