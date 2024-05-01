@echo on

cd cmd/%PKG_NAME%

go-licenses save . ^
    --save_path ../../library_licenses

set CGO_ENABLED=0
go install -v ^
    -ldflags "-s -w -X 'tailscale.com/version.shortStamp=v%PKG_VERSION%'" ^
    .
