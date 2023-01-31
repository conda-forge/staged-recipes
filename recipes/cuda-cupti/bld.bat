if not exist %PREFIX% mkdir %PREFIX%

move lib\x64\* %LIBRARY_LIB%
move include\* %LIBRARY_INC%
move doc\* %LIBRARY_INC%
move samples\* %LIBRARY_INC%
