@echo on

set "PROTOBUF_INCLUDE_DIR=%LIBRARY_INC%"
set "PROTOBUF_LIB_DIR=%LIBRARY_LIB%"
set "PROTOC=%LIBRARY_BIN%/protoc.exe"
set "EXTRA_COMPILE_ARGS=/DPROTOBUF_USE_DLLS"

cd mysqlx-connector-python
%PYTHON% -m pip install . --no-deps --verbose
