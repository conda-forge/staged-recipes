@echo on

%PYTHON% -m pip install engine\language_client_python\ || goto :error

pushd engine\language_client_python || goto :error
cargo-bundle-licenses --format yaml --output %SRC_DIR%\THIRDPARTY.yml || goto :error
popd || goto :error

