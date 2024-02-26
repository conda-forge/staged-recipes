set SRCDIR="src"
set SRCDATADIR="%SRCDIR%\mcxtrace-comps\data"
set DESTDATADIR="%PREFIX%\share\mcxtrace\resources\data"
mkdir %DESTDATADIR%
xcopy /e %SRCDATADIR% %DESTDATADIR%
echo  "mcxtrace-data-%PKG_VERSION%" > "%DESTDATADIR%\.mcxtrace-data-version-conda.txt"
