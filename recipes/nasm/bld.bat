nmake /f Mkfiles\msvc.mak
if errorlevel 1 exit 1

copy nasm.exe "%LIBRARY_BIN%\nasm.exe"
if errorlevel 1 exit 1

copy ndisasm.exe "%LIBRARY_BIN%\ndisasm.exe"
if errorlevel 1 exit 1
