@echo ON

go build -v ^
    -trimpath ^
    -modcacherw ^
    -ldflags="-w -s -X main.version=%PKG_VERSION%" ^
    -o "%LIBRARY_BIN%\gha-doctor.exe" ^
    ./cmd/gha-doctor ^
    || exit 1

"%LIBRARY_BIN%\gha-doctor.exe" --version || exit 1

go-licenses save ./cmd/gha-doctor --save_path library_licenses ^
    || exit 1
