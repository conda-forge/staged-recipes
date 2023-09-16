setx CARGO_PKG_VERSION %PKG_VERSION%

mkdir %PREFIX%\\Library
mkdir %PREFIX%\\Library\\include

cp webgpu.h %PREFIX%\\Library\\include\\webgpu.h
if %ERRORLEVEL% neq 0 exit 1
