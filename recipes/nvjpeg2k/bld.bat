
:: Relocate CUDA major specific libraries to single prefix layout

for /f "tokens=1 delims=." %%a in ("%cuda_compiler_version%") do (
    set "CUDA_MAJOR=%%a"
    break
)

move lib lib.backup
move lib.backup\%CUDA_MAJOR% lib
del lib.backup

if not exist %PREFIX% mkdir %PREFIX%

move lib\*.lib %LIBRARY_LIB%
move lib\*.dll %LIBRARY_BIN%
move include\* %LIBRARY_INC%
