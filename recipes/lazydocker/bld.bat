@echo on

cd %SRC_DIR%

go build -v -o "%LIBRARY_BIN%\lazydocker.exe" "%SRC_DIR%"
