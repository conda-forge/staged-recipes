@echo on

go build -a -v ^
    -ldflags "-s -w -X main.Version=%PKG_VERSION%" ^
    -o "%LIBRARY_BIN%\%PKG_NAME%.exe" "%SRC_DIR%"

go-licenses save . --save_path=./license-files
