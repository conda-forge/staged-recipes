# Backup existing OCL_ICD_FILENAMES
export OCL_ICD_FILENAMES_CONDA_BACKUP="${OCL_ICD_FILENAMES:-}"

# System-wide Intel ICD file locations to search
# Priority order: newest driver locations first
INTEL_ICD_PATHS=(
    "/etc/OpenCL/vendors/intel.icd"
    "/etc/OpenCL/vendors/intel-ocl-gpu.icd"
)

# Find the first existing Intel ICD file
INTEL_ICD_FILE=""
for icd_path in "${INTEL_ICD_PATHS[@]}"; do
    if [ -f "$icd_path" ]; then
        INTEL_ICD_FILE="$icd_path"
        break
    fi
done

# If we found an Intel ICD file, read its library path and add to OCL_ICD_FILENAMES
if [ -n "$INTEL_ICD_FILE" ]; then
    # Read the library path from the ICD file
    INTEL_LIB_PATH=$(cat "$INTEL_ICD_FILE" 2>/dev/null | tr -d '\r\n')

    if [ -n "$INTEL_LIB_PATH" ]; then
        # Add Intel library to OCL_ICD_FILENAMES
        if [ -z "$OCL_ICD_FILENAMES" ]; then
            export OCL_ICD_FILENAMES="$INTEL_LIB_PATH"
        else
            export OCL_ICD_FILENAMES="$INTEL_LIB_PATH:${OCL_ICD_FILENAMES}"
        fi
    fi
fi
