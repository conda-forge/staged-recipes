"%PREFIX%\Library\bin\glib-compile-schemas.exe" "%PREFIX%\Library\share\glib-2.0\schemas"
if errorlevel 1 exit 1
"%PREFIX%\Library\bin\gtk4-update-icon-cache.exe" -f -t "%PREFIX%\Library\share\icons\hicolor"
if errorlevel 1 exit 1
"%PREFIX%\Library\bin\gio-querymodules.exe" "%PREFIX%\Library\lib\gtk-4.0\4.0.0\printbackends"
if errorlevel 1 exit 1
