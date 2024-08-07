@echo on

cd cmd/golangci-lint

go-licenses save . ^
    --save_path ../../library_licenses ^
    --ignore github.com/golangci/golangci-lint
go install -v .
