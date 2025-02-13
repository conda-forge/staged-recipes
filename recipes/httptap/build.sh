
#!/bin/bash

set -ex

cd $SRC_DIR
go build -v -o $PREFIX/bin/httptap
go-licenses save . --save_path ./library_licenses