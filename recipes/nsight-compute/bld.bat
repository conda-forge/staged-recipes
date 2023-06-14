setlocal enableDelayedExpansion
for /F "tokens=1,2,3 delims=. " %%a in ("%PKG_VERSION%") do (
   set "version=%%a.%%b.%%c"
)
rmdir /q /s nsight-compute\!version!\lib

move nsight-compute %LIBRARY_PREFIX%

mklink /h %LIBRARY_BIN%\ncu %LIBRARY_PREFIX%\nsight-compute\!version!\ncu.bat
