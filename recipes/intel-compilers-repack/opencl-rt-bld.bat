mkdir "%LIBRARY_PREFIX%\intel-ocl-cpu"
set "src=%SRC_DIR%\%PKG_NAME%\Library\lib"
robocopy /E "%src%" "%LIBRARY_LIB%\intel-ocl-cpu"
if %ERRORLEVEL% GEQ 8 exit 1

mkdir "%LIBRARY_PREFIX%\etc\OpenCL\vendors\"
echo %LIBRARY_LIB%\intel-ocl-cpu\intelocl64.dll> %LIBRARY_PREFIX%\etc\OpenCL\vendors\intel-ocl-cpu.icd
