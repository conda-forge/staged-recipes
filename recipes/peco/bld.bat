@echo on

cd %SRC_DIR%

go build ^
    -ldflags "-s -w -X main.Version=%PKG_VERSION%" ^
    -o "%PREFIX%/bin/%PKG_NAME%" ^
    "cmd/%PKG_NAME%/%PKG_NAME%.go"
