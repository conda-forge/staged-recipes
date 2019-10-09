conda_ocl_icd_system_activate () {
    # If no OpenCL ICD has been installed with conda yet
    if [[ -z "$(ls ${CONDA_PREFIX}/etc/OpenCL/vendors/)" ]]; then
        ln -s /etc/OpenCL/vendors "${CONDA_PREFIX}"/etc/OpenCL/vendors/system
        touch "${CONDA_PREFIX}"/etc/OpenCL/vendors/.ocl_icd_system_cf
    fi;
}

conda_ocl_icd_system_activate || true