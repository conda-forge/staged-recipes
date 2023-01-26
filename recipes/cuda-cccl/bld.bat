if not exist %PREFIX% mkdir %PREFIX%

move lib\cmake %LIBRARY_LIB%
move include\cub %LIBRARY_INC%
move include\cuda %LIBRARY_INC%
move include\nv %LIBRARY_INC%
move include\thrust %LIBRARY_INC%
