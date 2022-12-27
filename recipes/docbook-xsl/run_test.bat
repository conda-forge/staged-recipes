@echo off

if not exist "%PREFIX%\share\%PKG_NAME%\\" exit /b 1


:: See run_test.sh.
set XML_CATALOG_FILES=%PREFIX%\etc\xml\catalog

echo system http://cdn.docbook.org/release/xsl/current/ | xmlcatalog --shell | findstr /r /c:"^> file://"
