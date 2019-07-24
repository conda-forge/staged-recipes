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

# Create `nvcc` script in `bin` so it can be easily run.
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/nvcc" <<'EOF'
#!/bin/bash
"${CUDA_HOME}/bin/nvcc" -ccbin "${CXX}" $@
EOF
chmod +x "${PREFIX}/bin/nvcc"

# Add `libcuda.so` shared object stub to the compiler sysroot.
# Needed for things that want to link to `libcuda.so`.
# Stub is used to avoid getting driver code linked into binaries.
CONDA_BUILD_SYSROOT="$(${CC} --print-sysroot)"
mkdir -p "${CONDA_BUILD_SYSROOT}"
mkdir -p "${CONDA_BUILD_SYSROOT}/lib"
ln -s "${CUDA_HOME}/lib64/stubs/libcuda.so" "${CONDA_BUILD_SYSROOT}/lib/libcuda.so"
mkdir -p "${CONDA_BUILD_SYSROOT}/bin"
ln -s "${CC}" "${CONDA_BUILD_SYSROOT}/bin/gcc"
ln -s "${CXX}" "${CONDA_BUILD_SYSROOT}/bin/g++"
