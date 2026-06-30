"""Install the prebuilt livekit-local-inference wheel and surface its license files.

"""
import glob
import os
import shutil
import subprocess
import sys

src_dir = os.environ["SRC_DIR"]
sp_dir = os.environ["SP_DIR"]

wheel = glob.glob(os.path.join(src_dir, "*.whl"))[0]
subprocess.check_call(
    [
        sys.executable,
        "-m",
        "pip",
        "install",
        "--no-deps",
        "--no-index",
        "--no-build-isolation",
        wheel,
        "-vv",
    ]
)

dist_info = glob.glob(os.path.join(sp_dir, "livekit_local_inference-*.dist-info"))[0]
for name in ("LICENSE", "MODEL_LICENSE"):
    shutil.copy(os.path.join(dist_info, "licenses", name), os.path.join(src_dir, name))
