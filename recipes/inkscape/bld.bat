rem I want to see my commands when they go wrong...
echo on

7za x Inkscape-0.91-1.7z -o%LIBRARY_PREFIX%
if errorlevel 1 exit 1
mkdir %SCRIPTS%
if errorlevel 1 exit 1
rem inkscape.exe is the GUI, the .com is the commandline utility we need in other packages
echo @"%%~dp0\..\Library\inkscape\inkscape.com" %%* >> "%SCRIPTS%\inkscape.bat"
if errorlevel 1 exit 1