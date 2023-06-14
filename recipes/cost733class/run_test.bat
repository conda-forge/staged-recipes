if not exist %LIBRARY_BIN%\\cost733class.exe exit 1

%LIBRARY_BIN%\\cost733class.exe -v 3 -dat pth:slp.dat lon:-10:30:2.5 lat:35:60:2.5 fdt:2000:1:1:12 ldt:2008:12:31:12 ddt:1d
if errorlevel 1 exit 1