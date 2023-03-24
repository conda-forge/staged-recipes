if not exist %PREFIX% mkdir %PREFIX%
mkdir %LIBRARY_LIB%\x64
mkdir %LIBRARY_INC%\targets
mkdir %LIBRARY_INC%\targets\x64

move lib\cmake %LIBRARY_LIB%\x64
move include\cub %LIBRARY_INC%\targets\x64
move include\cuda %LIBRARY_INC%\targets\x64
move include\nv %LIBRARY_INC%\targets\x64
move include\thrust %LIBRARY_INC%\targets\x64
