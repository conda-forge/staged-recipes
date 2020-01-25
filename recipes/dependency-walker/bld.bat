xcopy depends.* %LIBRARY_BIN% || exit 1
copy depends.dll %LIBRARY_BIN%\mfc42.dll || exit 1
