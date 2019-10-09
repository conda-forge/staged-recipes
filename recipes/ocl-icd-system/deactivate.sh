conda_ocl_icd_system_deactivate () {
    if [[ -f "${CONDA_PREFIX}"/etc/OpenCL/vendors/.ocl_icd_system_cf ]]; then
        rm "${CONDA_PREFIX}"/etc/OpenCL/vendors/system
        rm "${CONDA_PREFIX}"/etc/OpenCL/vendors/.ocl_icd_system_cf
    fi;
}

conda_ocl_icd_system_deactivate || true