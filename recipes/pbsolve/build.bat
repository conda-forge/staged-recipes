@echo on
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
if not "%cuda_compiler_version%"=="None" (
  for /f "tokens=1 delims=." %%a in ("%cuda_compiler_version%") do set "MATURIN_PEP517_ARGS=--features cuda-%%a"
)
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation || exit 1
