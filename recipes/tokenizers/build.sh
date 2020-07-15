${SRC_DIR}/rust-nightly/install.sh --verbose --prefix=${SRC_DIR}/rust-nightly-install --disable-ldconfig
export PATH=${SRC_DIR}/rust-nightly-install/bin:$PATH
# maturin build --no-sdist --release --strip --manylinux off
# "${PYTHON}" -m pip install . -vv
$PYTHON setup.py install