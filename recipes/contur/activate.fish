#!/usr/bin/env fish

set -gx CONTUR_ROOT "$CONDA_PREFIX"
set -gx CONTUR_DATA_PATH "$CONDA_PREFIX/share/contur"
set -gx CONTUR_USER_DIR "$CONDA_PREFIX/contur_users"

# if CONTUR_USER_DIR does not exist create it
if not test -d "$CONTUR_USER_DIR"
    mkdir -p "$CONTUR_USER_DIR"
end

# preserve the existing settings
if set -q RIVET_DATA_PATH
    set -gx _CONDA_BACKUP_RIVET_DATA_PATH "$RIVET_DATA_PATH"
end
if set -q RIVET_ANALYSIS_PATH
    set -gx _CONDA_BACKUP_RIVET_ANALYSIS_PATH "$RIVET_ANALYSIS_PATH"
end
set -gx RIVET_DATA_PATH "$CONTUR_DATA_PATH/data/Rivet:$CONTUR_DATA_PATH/data/Theory:$RIVET_DATA_PATH"
set -gx RIVET_ANALYSIS_PATH "$CONTUR_DATA_PATH/data/Rivet:$CONTUR_USER_DIR:$RIVET_ANALYSIS_PATH"


if not test -f "$CONTUR_USER_DIR/analysis-list"
    set -l _return_path (pwd -P)
    cd "$CONTUR_DATA_PATH"
    make
    cd "$_return_path"
end
if test -f "$CONTUR_USER_DIR/analysis-list"
    source "$CONTUR_USER_DIR/analysis-list"
end
