#!/usr/bin/env bash

set -exo pipefail

prefix="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd -P)"
root="${prefix}/lib/isaac-sim"
python_mm="$("${prefix}/bin/python" - <<'PY'
import sys
print(f"{sys.version_info[0]}.{sys.version_info[1]}")
PY
)"

export ISAACSIM_ROOT="${root}"
export PATH="${root}:${root}/kit:${prefix}/bin:${PATH}"
export LD_LIBRARY_PATH="${root}:${root}/kit:${root}/kit/lib:${prefix}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export PYTHONPATH="${prefix}/lib/${python_mm}/site-packages${PYTHONPATH:+:${PYTHONPATH}}"
unset PYTHONHOME

exec "${root}/isaac-sim.sh" "$@"
