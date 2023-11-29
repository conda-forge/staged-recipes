set SRCDIR="src"
set SRCDATADIR="%SRCDIR%\mcstas-comps\data"
set DESTDATADIR="%PREFIX%\share\mcstas\resources\data"
mkdir %DESTDATADIR%
xcopy /e %SRCDATADIR% %DESTDATADIR%
echo  "mcstas-data-%PKG_VERSION%" > "%DESTDATADIR%\.mcstas-data-version-conda.txt"
