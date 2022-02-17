maturin build --rustc-extra-args="-C codegen-units=16 -C lto=thin -C target-cpu=native" --release
cd ./target/wheels
$PYTHON -m pip install --no-deps --ignore-installed -vv *.whl
