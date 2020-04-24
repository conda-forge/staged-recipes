@echo on

:: nothing more to do than copy "index.theme" to the right location

md "%LIBRARY_PREFIX%\share\icons\hicolor"
copy "index.theme" "%LIBRARY_PREFIX%\share\icons\hicolor\index.theme"
if errorlevel 1 exit 1
