@echo on
set "TCLDIR=%BUILD_PREFIX%\Library"

:: build sqldiff
nmake /f Makefile.msc sqldiff.exe TCLDIR=%TCLDIR%
if %ERRORLEVEL% neq 0 exit 1

:: build sqlite3_rsync
nmake /f Makefile.msc sqlite3_rsync.exe TCLDIR=%TCLDIR%
if %ERRORLEVEL% neq 0 exit 1

:: build sqlite3_analyzer
nmake /f Makefile.msc STATICALLY_LINK_TCL=0 sqlite3_analyzer.exe TCLDIR=%TCLDIR%
if %ERRORLEVEL% neq 0 exit 1

COPY sqldiff.exe %LIBRARY_BIN% || exit 1
COPY sqlite3_rsync.exe %LIBRARY_BIN% || exit 1
COPY sqlite3_analyzer.exe %LIBRARY_BIN%\sqlite3_analyze.exe || exit 1
