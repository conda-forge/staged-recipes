if not exist %PREFIX% mkdir %PREFIX%

rmdir /q /s compute-sanitizer\x86

move compute-sanitizer %LIBRARY_PREFIX%

mklink /h %LIBRARY_BIN%\compute-sanitizer %LIBRARY_PREFIX%\compute-sanitizer\compute-sanitizer.exe
