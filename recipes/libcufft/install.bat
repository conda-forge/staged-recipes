if not exist %PREFIX% mkdir %PREFIX%
if not exist %LIBRARY_LIB% mkdir %LIBRARY_LIB%
if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN%
if not exist %LIBRARY_INC% mkdir %LIBRARY_INC%

move lib\x64\* %LIBRARY_LIB%
move bin\* %LIBRARY_BIN%
move include\* %LIBRARY_INC%
