
zpaq.exe add archive.zpaq "%LIBRARY_BIN%"\zpaq.exe || exit 1
zpaq.exe extract archive.zpaq "%LIBRARY_BIN%"\zpaq.exe -to zpaq.new || exit 1
fc /b "%LIBRARY_BIN%"\zpaq.exe zpaq.new || exit 1
del archive.zpaq zpaq.new
