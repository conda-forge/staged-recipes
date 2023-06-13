if not exist %PREFIX% mkdir %PREFIX%

move lib\x64\* %LIBRARY_LIB%
move include\* %LIBRARY_INC%

 not exist %LIBRARY_PREFIX%\etc mkdir %LIBRARY_PREFIX%\etc
 not exist %LIBRARY_PREFIX%\etc\OpenCL mkdir %LIBRARY_PREFIX%\etc\OpenCL
 not exist %LIBRARY_PREFIX%\etc\OpenCL\vendors mkdir %LIBRARY_PREFIX%\etc\OpenCL\vendors
 type nul >> %LIBRARY_PREFIX%\etc\OpenCL\vendors\cuda.icd
