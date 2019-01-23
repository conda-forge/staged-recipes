if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
move pandoc-crossref.exe %LIBRARY_BIN% || exit 1
