@ECHO ON

copy %PREFIX%\\Library\\include\\webgpu.h ffi\\webgpu.h

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if %ERRORLEVEL% neq 0 (type CMakeError.log && exit 1)

cargo build --release --all-features
if %ERRORLEVEL% neq 0 (type CMakeError.log && exit 1)

copy ffi\\wgpu.h %PREFIX%\\Library\\include\\wgpu.h
if %ERRORLEVEL% neq 0 (type CMakeError.log && exit 1)

dir target\
