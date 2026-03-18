#!/usr/bin/env bash

if [ -n "${OCL_ICD_VENDORS:-}" ]; then
  export _OLD_OCL_ICD_VENDORS_INTEL_GPU_OCL_ICD_SYSTEM="${OCL_ICD_VENDORS}"
  export OCL_ICD_VENDORS="/etc/OpenCL/vendors:${CONDA_PREFIX}/etc/OpenCL/vendors:${OCL_ICD_VENDORS}"
else
  export _OLD_OCL_ICD_VENDORS_INTEL_GPU_OCL_ICD_SYSTEM=""
  export OCL_ICD_VENDORS="/etc/OpenCL/vendors:${CONDA_PREFIX}/etc/OpenCL/vendors"
fi
