@echo on

:: first, build remaining code from anserini-tools
cd tools/eval/ndeval
:: compile ndeval
make
if %ERRORLEVEL% neq 0 exit 1

cd %SRC_DIR%

mvn clean package appassembler:assemble
if %ERRORLEVEL% neq 0 exit 1

mkdir %LIBRARY_LIB%
mkdir %LIBRARY_BIN%

:: TODO: copy correct jar & binaries
:: cp %SRC_DIR\target\<something>.jar %LIBRARY_LIB%
