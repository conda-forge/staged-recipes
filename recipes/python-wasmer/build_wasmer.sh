#!/usr/bin/env bash
set -x

if [[ $PKG_NAME == "python-wasmer" ]]; then
    maturin build --bindings pyo3  --release --strip --interpreter $PYTHON --out wheels -m packages/api/Cargo.toml
fi

if [[ $PKG_NAME == "python-wasmer-compiler-cranelift" ]]; then
    maturin build --bindings pyo3 --release --strip --interpreter $PYTHON --out wheels -m packages/compiler-cranelift/Cargo.toml
fi 

if [[ $PKG_NAME == "python-wasmer-compiler-singlepass" ]]; then
    maturin build --bindings pyo3 --release --strip --interpreter $PYTHON --out wheels -m packages/compiler-singlepass/Cargo.toml
fi 

if [[ $PKG_NAME == "python-wasmer-compiler-llvm" ]]; then
    maturin build --skip-auditwheel --compatibility manylinux2014 --bindings pyo3 --release --strip --interpreter $PYTHON --out wheels -m packages/compiler-llvm/Cargo.toml
fi

$PYTHON -m pip install -vv --no-build-isolation --no-deps wheels/*.whl

if [[ $PKG_NAME == "python-wasmer" ]]; then
    pytest tests/test_type.py
    pytest tests/test_value.py
fi

if [[ $PKG_NAME == "python-wasmer-compiler-cranelift" ]]; then
    pytest tests/test_store.py
    pytest tests/test_target.py
fi

if [[ $PKG_NAME == "python-wasmer-compiler-llvm" ]]; then
    pytest tests
fi

