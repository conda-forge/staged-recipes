@echo on

go build -a -v ^
    -mod=vendor ^
    -ldflags "-s -w -X main.Version=%PKG_VERSION%" ^
    -o "%LIBRARY_BIN%\lazydocker.exe" "%SRC_DIR%"

go-licenses save . --save_path=./license-files
