if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
move pandoc-plot.exe %LIBRARY_BIN% || exit 1