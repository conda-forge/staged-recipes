maturin build --rustc-extra-args="-C codegen-units=16 -C lto=thin -C target-cpu=native" --release
cd .\target\wheels
%PYTHON% -m pip install --no-deps --ignore-installed -vv polars-%PKG_VERSION%-cp36-abi3-win_amd64.whl

# TODO: fix filename wildcard