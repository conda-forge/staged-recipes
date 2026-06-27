#!/usr/bin/env bash
# post-link.sh
# Runs after the package is linked into the target environment.
# Conda sets $PREFIX to the target environment path.

set -euo pipefail

MSG_FILE="${PREFIX}/.messages.txt"

{
  echo
  echo "============================================"
  echo "PyGeNN CUDA backend installed"
  echo "============================================"
  echo
  echo "To enable CUDA for runtime code generation, set the following in your shell"
  echo 
  echo "--- Use this conda env's modular CUDA ---"
  echo "    export CUDA_PATH=\${CONDA_PREFIX}"
  echo "    # Optional if your loader can't find libcudart:"
  echo "    # export LD_LIBRARY_PATH=\${CONDA_PREFIX}/lib:\${LD_LIBRARY_PATH:-}"
  echo
  echo "--- To choose a CUDA Toolkit version, install this package with e.g.: ---"
  echo "    conda install pygenn cuda-version=12.4"
  echo
  echo "Notes:"
  echo " - Ensure nvcc and libcudart match your chosen CUDA_PATH."
  echo " - Verify with:"
  echo "       nvcc --version"
  echo "       python - <<'PY'; import pygenn; print('pygenn import OK'); PY"
  echo " - Runtime code generation requires 'make' and a C++ compiler (the recipe adds these on Linux)."
  echo "============================================"
  echo
} > "${MSG_FILE}" || true

# Show the message during install (best-effort)
cat "${MSG_FILE}" || true

exit 0
