#!/usr/bin/env fish

# Restore previous env vars if they were set.
set -e NCVIS_RESOURCE_DIR
if set -q _CONDA_SET_NCVIS_RESOURCE_DIR
    set -gx  NCVIS_RESOURCE_DIR "$_CONDA_SET_NCVIS_RESOURCE_DIR"
    set -e _CONDA_SET_NCVIS_RESOURCE_DIR
end