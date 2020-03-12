@echo OFF

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

if %OS%==32BIT copy win\stride_win32.exe "%LIBRARY_BIN%"\stride.exe
if %OS%==64BIT copy win\stride_win64.exe "%LIBRARY_BIN%"\stride.exe