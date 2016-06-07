rem I want to see my commands when they go wrong...
echo on

mkdir %SCRIPTS%
if errorlevel 1 exit 1

rem inkscape.exe is the GUI, the .com is the commandline utility we need in other packages

rem compile using the MS compilers
cl -DGUI=0 -DDEBUG=0 "%RECIPE_DIR%\wrapper.c"
if errorlevel 1 exit 1

dumpbin /IMPORTS wrapper.exe

copy "wrapper.exe" "%SCRIPTS%\inkscape.exe"
if errorlevel 1 exit 1

del wrapper.exe
del wrapper.obj

rem last to see compile errors faster...
7za x Inkscape-0.91-1.7z -o%LIBRARY_PREFIX%
if errorlevel 1 exit 1
