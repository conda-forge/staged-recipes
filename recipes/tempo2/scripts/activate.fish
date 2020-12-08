#!/usr/bin/env fish

if set -q TEMPO2
  set -gx _CONDA_SET_TEMPO2 "$TEMPO2"
end

set -gx TEMPO2 "$CONDA_PREFIX/share/tempo2"
