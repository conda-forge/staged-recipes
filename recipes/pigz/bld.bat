set "XCFLAGS=/W3 /MT /nologo"

nmake
nmake test

copy pigz %LIBRARY_BIN%
copy unpigz %LIBRARY_BIN%
