# Seal the aether-dsc payload from the tagged sources, then install the package.
# The upstream release seals with an extra NVRTC compile check (CUDA, Linux only);
# here the digest check below proves the content is byte-identical to that release.
import os
import subprocess
import sys
from pathlib import Path

dsc = Path(os.environ["SRC_DIR"]) / "aether" / "dsc"
sys.path.insert(0, str(dsc))
from aether_dsc._core import PAYLOAD_DIR, _pack, digest_of  # noqa: E402
from aether_dsc._seal_impl import seal  # noqa: E402

payload = seal()
expected = os.environ["PAYLOAD_DIGEST"]
if payload.digest != expected:
    sys.exit(f"sealed digest {payload.digest} != released digest {expected}")
for stale in PAYLOAD_DIR.glob("*.bin"):
    stale.unlink()
(PAYLOAD_DIR / f"{payload.digest}.bin").write_bytes(_pack(payload.headers, payload.host_only_names))
print(f"sealed {len(payload.headers)} headers, digest {payload.digest}")

subprocess.check_call([sys.executable, "-m", "pip", "install", str(dsc), "-vv",
                       "--no-deps", "--no-build-isolation"])
