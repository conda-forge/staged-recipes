@echo on

make
if %ERRORLEVEL% neq 0 exit 1

:: install
mkdir -p %LIBRARY_BIN%
cp trec_eval %LIBRARY_BIN%\trec_eval
