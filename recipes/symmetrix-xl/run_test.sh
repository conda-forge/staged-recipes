#!/usr/bin/env bash

set -euo pipefail

python - <<'PY'
from importlib.metadata import version
from pathlib import Path

import symmetrix

assert version("symmetrix-xl") == "0.1.1"
assert Path(symmetrix.__file__).is_file()
PY

pip check
symmetrix backend show --probe
symmetrix doctor --json > doctor.json
grep -q '"status": "ok"' doctor.json
