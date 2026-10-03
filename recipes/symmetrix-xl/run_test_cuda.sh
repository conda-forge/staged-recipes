#!/usr/bin/env bash

set -euo pipefail

python - <<'PY'
import json
from importlib import import_module
from importlib.metadata import PackageNotFoundError, entry_points, version
from pathlib import Path

architectures = {
    "cuda12-sm80": "sm80",
    "cuda12-sm120": "sm120",
}
installed = []
for candidate in architectures:
    try:
        version(f"symmetrix-xl-{candidate}")
    except PackageNotFoundError:
        continue
    installed.append(candidate)
assert len(installed) == 1, installed
selector = installed[0]
architecture = architectures[selector]
module_token = selector.replace("-", "_")
package = f"symmetrix_backend_{module_token}"
distribution = f"symmetrix-xl-{selector}"
backend = import_module(package)

assert version(distribution) == "0.1.1"
assert version("symmetrix-xl") == "0.1.1"
descriptor = Path(backend.__file__).with_name("backend.json")
assert descriptor.is_file()
metadata = json.loads(descriptor.read_text())
assert metadata["backend"] == "cuda"
assert metadata["selector"] == selector
assert metadata["architecture"] == architecture
assert metadata["distribution"] == distribution
points = entry_points(group="symmetrix.backends")
assert any(
    point.name == selector and point.value == package
    for point in points
)
matches = list(Path(backend.__file__).parent.glob(f"_native_{module_token}*.so"))
assert len(matches) == 1, matches
print(matches[0])
PY

pip check

native=$(python - <<'PY'
from importlib.metadata import PackageNotFoundError, version
from importlib import import_module
from pathlib import Path

selectors = ("cuda12-sm80", "cuda12-sm120")
installed = []
for selector in selectors:
    try:
        version(f"symmetrix-xl-{selector}")
    except PackageNotFoundError:
        continue
    installed.append(selector)
assert len(installed) == 1, installed
module_token = installed[0].replace("-", "_")
backend = import_module(f"symmetrix_backend_{module_token}")
print(next(Path(backend.__file__).parent.glob(f"_native_{module_token}*.so")))
PY
)
driver_stub_directory=$(mktemp -d)
trap 'rm -rf -- "$driver_stub_directory"' EXIT
driver_stub=$(find "${PREFIX}" \( -type f -o -type l \) \
  -path '*/stubs/libcuda.so' -print -quit)
test -n "${driver_stub}"
ln -s "${driver_stub}" "${driver_stub_directory}/libcuda.so.1"
export LD_LIBRARY_PATH="${driver_stub_directory}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
linkage=$(ldd "${native}")
if grep -q 'not found' <<<"${linkage}"; then
  exit 1
fi
for library in libcudart libcublas; do
  grep -E "^[[:space:]]*${library}\\.so[^[:space:]]* => ${PREFIX}/(bin/\\.\\./)?lib/" \
    <<<"${linkage}"
done
