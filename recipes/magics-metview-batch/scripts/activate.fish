#!/bin/fish
# Store existing env vars so we can restore them later
if set -q MAGPLUS_HOME
    set -gx _CONDA_SET_MAGPLUS_HOME "$MAGPLUS_HOME"
end

set -gx MAGPLUS_HOME "$CONDA_PREFIX"
