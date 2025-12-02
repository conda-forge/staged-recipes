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
  echo "To enable CUDA for runtime code generation, set ONE of the following in your shell"
  echo "(pick either this conda environment's modular CUDA or a system CUDA):"
  echo
  echo "--- Option A: Use this conda env's modular CUDA ---"
  echo "    export CUDA_PATH=\${CONDA_PREFIX}"
  echo "    # Optional if your loader can't find libcudart:"
  echo "    # export LD_LIBRARY_PATH=\${CONDA_PREFIX}/lib:\${LD_LIBRARY_PATH:-}"
  echo
  echo "--- Option B: Use a system CUDA install (example path) ---"
  echo "    export CUDA_PATH=/usr/local/cuda-12.x"
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
