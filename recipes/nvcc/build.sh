#!/bin/bash

set -xeuo pipefail

# Default to using `nvcc` to specify `CUDA_HOME`.
if [ -z ${CUDA_HOME+x} ]
then
    CUDA_HOME="$(dirname $(dirname $(which nvcc)))"
fi

# Set `CUDA_HOME` in an activation script.
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOF
#!/bin/bash
export CUDA_HOME="${CUDA_HOME}"
EOF

# Unset `CUDA_HOME` in a deactivation script.
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOF
#!/bin/bash
unset CUDA_HOME
EOF

# Symlink `nvcc` into `bin` so it can be easily run.
mkdir -p "${PREFIX}/bin"
ln -s "${CUDA_HOME}/bin/nvcc" "${PREFIX}/bin/nvcc"

# Add `libcuda.so` shared object stub to the compiler sysroot.
# Needed for things that want to link to `libcuda.so`.
# Stub is used to avoid getting driver code linked into binaries.
CONDA_BUILD_SYSROOT="$(${CC} --print-sysroot)"
mkdir -p "${CONDA_BUILD_SYSROOT}/lib"
ln -s "${CUDA_HOME}/lib64/stubs/libcuda.so" "${CONDA_BUILD_SYSROOT}/lib/libcuda.so"
