#!/usr/bin/env fish

if set -q NCVIS_RESOURCE_DIR
  set -gx _CONDA_SET_NCVIS_RESOURCE_DIR "$NCVIS_RESOURCE_DIR"
end

set -gx NCVIS_RESOURCE_DIR "$CONDA_PREFIX/share/ncvis/resources"