cd tensorboard/data/server
cargo build --release
cd pip_package
$PYTHON build.py --out-dir="$SRC_DIR/" --server-binary=../target/release/rustboard
$PYTHON -m pip install --no-deps --ignore-installed -v $SRC_DIR/*.whl
