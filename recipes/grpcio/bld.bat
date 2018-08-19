set "GRPC_PYTHON_BUILD_SYSTEM_ZLIB=True"
set "GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True"
set "GRPC_PYTHON_CFLAGS=/DPB_FIELD_16BIT"

"%PYTHON%" -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
if errorlevel 1 exit 1
