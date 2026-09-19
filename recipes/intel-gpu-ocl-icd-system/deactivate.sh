# Restore original OCL_ICD_FILENAMES
if [ -n "${OCL_ICD_FILENAMES_CONDA_BACKUP+x}" ]; then
    export OCL_ICD_FILENAMES="$OCL_ICD_FILENAMES_CONDA_BACKUP"
    unset OCL_ICD_FILENAMES_CONDA_BACKUP

    # If the restored value is empty, unset the variable
    if [ -z "$OCL_ICD_FILENAMES" ]; then
        unset OCL_ICD_FILENAMES
    fi
fi
