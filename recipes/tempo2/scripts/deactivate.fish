#!/sr/bin/env fish

set -e TEMPO2

if set -q _CONDA_SET_TEMPO2
  set -gx TEMPO2 "$_CONDA_SET_TEMPO2"
  set -e _CONDA_SET_TEMPO2
end
