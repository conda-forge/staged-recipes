@echo on

cd cmd/atlas

go-licenses save . ^
    --save_path ../../library_licenses ^
    --ignore ariga.io/atlas ^
    --ignore github.com/libsql/sqlite-antlr4-parser

go install -v .
