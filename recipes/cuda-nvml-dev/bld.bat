if not exist %PREFIX% mkdir %PREFIX%

move lib\x64\* %LIBRARY_LIB%
move include\* %LIBRARY_INC%
mkdir %PREFIX%\nvml
move nvml\* %PREFIX%\nvml
