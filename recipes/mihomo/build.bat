@echo on
@setlocal EnableDelayedExpansion

set CGO_ENABLED=0
set GOFLAGS=%GOFLAGS% -tags=with_gvisor

if defined SOURCE_DATE_EPOCH (
    for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "[DateTimeOffset]::FromUnixTimeSeconds([long]$env:SOURCE_DATE_EPOCH).UtcDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')"`) do set "BUILDTIME=%%I"
) else (
    for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "[DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')"`) do set "BUILDTIME=%%I"
)

go build -trimpath -ldflags="-s -w -buildid= -X github.com/metacubex/mihomo/constant.Version=%PKG_VERSION% -X github.com/metacubex/mihomo/constant.BuildTime=%BUILDTIME%" -o "%LIBRARY_BIN%\mihomo.exe" || goto :error

go-licenses save . --save_path library_licenses ^
    --ignore github.com/metacubex/mihomo ^
    --ignore github.com/metacubex/chacha ^
    --ignore github.com/metacubex/fswatch ^
    --ignore github.com/metacubex/sing-mux ^
    --ignore github.com/metacubex/sing-quic ^
    --ignore github.com/metacubex/sing-shadowsocks ^
    --ignore github.com/metacubex/sing-tun ^
    --ignore github.com/metacubex/sing-vmess ^
    --ignore github.com/metacubex/sing/ || goto :error

for %%P in (fswatch sing sing-mux sing-quic sing-shadowsocks sing-shadowsocks2 sing-tun sing-vmess) do (
    for /f "delims=" %%D in ('go list -m -f "{{.Dir}}" github.com/metacubex/%%P') do (
        if not exist "library_licenses\github.com\metacubex\%%P" mkdir "library_licenses\github.com\metacubex\%%P"
        copy /Y "%%D\LICENSE" "library_licenses\github.com\metacubex\%%P\LICENSE" || goto :error
    )
)

for /f "delims=" %%D in ('go list -m -f "{{.Dir}}" github.com/metacubex/chacha') do (
    if not exist "library_licenses\github.com\metacubex\chacha\chachapoly1305" mkdir "library_licenses\github.com\metacubex\chacha\chachapoly1305"
    if not exist "library_licenses\github.com\metacubex\chacha\poly1305" mkdir "library_licenses\github.com\metacubex\chacha\poly1305"
    copy /Y "%%D\chachapoly1305\LICENSE" "library_licenses\github.com\metacubex\chacha\chachapoly1305\LICENSE" || goto :error
    copy /Y "%%D\poly1305\LICENSE" "library_licenses\github.com\metacubex\chacha\poly1305\LICENSE" || goto :error
)

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
