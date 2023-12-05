echo ON
tar -xvf %SRC_DIR%\libcramjam-%VERSION%.crate
cd %SRC_DIR%\libcramjam-%VERSION%

cargo-bundle-licenses --format yaml --output %SRC_DIR%\\THIRDPARTY.yml
cargo cinstall --library-type cdylib --release --prefix %LIBRARY_PREFIX%
