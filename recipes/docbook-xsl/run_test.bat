@echo off

if not exist "%PREFIX%\share\%PKG_NAME%\\" exit /b 1
echo system http://cdn.docbook.org/release/xsl/current/ | xmlcatalog --shell | findstr /r /c:"^> file://"
