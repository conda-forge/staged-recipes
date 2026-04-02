#!/usr/bin/env bash

systemwide_vendors="/etc/OpenCL/vendors"
intel_icd_files=""

if [ -d "${systemwide_vendors}" ]; then
  matched_icd_files=$(grep -rl "libigdrcl" "${systemwide_vendors}" 2>/dev/null || true)
  if [ -n "${matched_icd_files}" ]; then
    intel_icd_files=$(printf "%s" "${matched_icd_files}" | tr "\n" ":" | sed 's/:$//')
  elif [ -f "${systemwide_vendors}/intel.icd" ]; then
    intel_icd_files="${systemwide_vendors}/intel.icd"
  fi
fi

if [ -n "${intel_icd_files}" ]; then
  if [ -n "${OCL_ICD_FILENAMES:-}" ]; then
    export _OLD_OCL_ICD_FILENAMES_INTEL_GPU_OCL_ICD_SYSTEM="${OCL_ICD_FILENAMES}"
    export OCL_ICD_FILENAMES="${intel_icd_files}:${OCL_ICD_FILENAMES}"
  else
    export _OLD_OCL_ICD_FILENAMES_INTEL_GPU_OCL_ICD_SYSTEM=""
    export OCL_ICD_FILENAMES="${intel_icd_files}"
  fi
fi
