bash %SRC_DIR%\rust-nightly\install.sh --verbose --prefix=%pfx% --disable-ldconfig
set PATH=%SRC_DIR%\rust-nightly-install\bin:%PATH%
maturin build --no-sdist --release --strip --manylinux off
%PYTHON% -m pip install . -vv