# Create activation/deactivation directories
mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"

# Copy activation/deactivation scripts
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/intel-gpu-ocl-icd-system-activate.sh"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/intel-gpu-ocl-icd-system-deactivate.sh"

# Make them executable
chmod +x "${PREFIX}/etc/conda/activate.d/intel-gpu-ocl-icd-system-activate.sh"
chmod +x "${PREFIX}/etc/conda/deactivate.d/intel-gpu-ocl-icd-system-deactivate.sh"
