#!/bin/fish
# Restore previous env vars if any
set -gx MAGPLUS_HOME

if set -q $_CONDA_SET_MAGPLUS_HOME
    set -gx MAGPLUS_HOME "$_CONDA_SET_MAGPLUS_HOME"
    set -gx _CONDA_SET_MAGPLUS_HOME
end
