@echo on

:: oapi-codegen/nullable is Apache-2.0, but go-licenses cannot classify its short-form
:: LICENSE notice, so it is ignored here and its LICENSE is copied in by hand.
:: https://github.com/oapi-codegen/nullable?tab=License-1-ov-file
go-licenses save . --save_path library_licenses ^
    --ignore github.com/oapi-codegen/nullable
if errorlevel 1 exit 1
mkdir library_licenses\github.com\oapi-codegen\nullable
for /f "delims=" %%d in ('go list -m -f "{{.Dir}}" github.com/oapi-codegen/nullable') do copy "%%d\LICENSE" library_licenses\github.com\oapi-codegen\nullable\
if errorlevel 1 exit 1

go build -trimpath -buildmode=pie ^
    -ldflags="-s -w -X github.com/git-pkgs/git-pkgs/cmd.version=%PKG_VERSION%" ^
    -o "%LIBRARY_BIN%\git-pkgs.exe" .
if errorlevel 1 exit 1
