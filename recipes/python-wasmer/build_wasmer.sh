#!/usr/bin/env bash
set -x

echo BUILDING $PKG_NAME for `python --version` on $target_platform
case "$target_platform" in
    linux-64) rust_env_arch=X86_64_UNKNOWN_LINUX_GNU ;;
    linux-aarch64) rust_env_arch=AARCH64_UNKNOWN_LINUX_GNU ;;
    linux-ppc64le) rust_env_arch=POWERPC64LE_UNKNOWN_LINUX_GNU ;;
    win-64) rust_env_arch=X86_64_PC_WINDOWS_MSVC ;;
    osx-64) rust_env_arch=X86_64_APPLE_DARWIN ;;
    osx-arm64) rust_env_arch=AARCH64_APPLE_DARWIN ;;
    *) echo "unknown target_platform $target_platform" ; exit 1 ;;
esac

export CARGO_TARGET_${rust_env_arch}_LINKER=$CC
export PYTHON_SYS_EXECUTABLE=$PYTHON

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

