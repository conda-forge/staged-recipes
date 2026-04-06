#!/usr/bin/env fish

set -e CONTUR_ROOT
set -e CONTUR_DATA_PATH
set -e CONTUR_USER_DIR

# reinstate the backup from outside the environment
if set -q _CONDA_BACKUP_RIVET_DATA_PATH
    set -gx RIVET_DATA_PATH "$_CONDA_BACKUP_RIVET_DATA_PATH"
    set -e _CONDA_BACKUP_RIVET_DATA_PATH
# no backup, just unset
else
    set -e RIVET_DATA_PATH
end

if set -q _CONDA_BACKUP_RIVET_ANALYSIS_PATH
    set -gx RIVET_ANALYSIS_PATH "$_CONDA_BACKUP_RIVET_ANALYSIS_PATH"
    set -e _CONDA_BACKUP_RIVET_ANALYSIS_PATH
# no backup, just unset
else
    set -e RIVET_ANALYSIS_PATH
end
