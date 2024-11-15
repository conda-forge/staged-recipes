
if not exist %PREFIX% mkdir %PREFIX%

move lib\*.lib %LIBRARY_LIB%
move lib\*.dll %LIBRARY_BIN%
move include\* %LIBRARY_INC%
