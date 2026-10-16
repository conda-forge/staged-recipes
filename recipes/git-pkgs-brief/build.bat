@echo on
@setlocal EnableDelayedExpansion

go build -o=%LIBRARY_PREFIX%\bin\brief.exe -ldflags="-s -w -X github.com/git-pkgs/brief.Version=%PKG_VERSION%" .\cmd\brief || goto :error

REM oapi-codegen/nullable's LICENSE file only contains the Apache-2.0 notice
REM boilerplate (not the full license text), so go-licenses can't classify it.
REM Ignore it in the scan and copy its real license in manually.
go-licenses save .\cmd\brief --save_path=license-files --ignore github.com/oapi-codegen/nullable || goto :error
mkdir license-files\github.com\oapi-codegen\nullable || goto :error
for /f "delims=" %%D in ('go list -m -f "{{ .Dir }}" github.com/oapi-codegen/nullable') do set NULLABLE_DIR=%%D
copy "%NULLABLE_DIR%\LICENSE" license-files\github.com\oapi-codegen\nullable\LICENSE || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
