set -ex

maturin develop -m kornia-py/Cargo.toml --release

cd target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl