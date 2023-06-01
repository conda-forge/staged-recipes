if not exist %PREFIX% mkdir %PREFIX%

move lib\x64\* %LIBRARY_LIB%
move bin\* %LIBRARY_BIN%
move include\* %LIBRARY_INC%
