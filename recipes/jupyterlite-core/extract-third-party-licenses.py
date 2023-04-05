"""extract the third-party-licenses.json file from the app bundle"""
from pathlib import Path
import os
import tarfile
import sys
import json

SRC_DIR = Path(os.environ["SRC_DIR"])
CORE_SRC = SRC_DIR / "jupyterlite-core"
MOD_SRC = CORE_SRC / "jupyterlite_core"
APP_TGZ = MOD_SRC / f"""jupyterlite-app-{os.environ["PKG_VERSION"]}.tgz"""
TPLJ = "third-party-licenses.json"
CORE_TPLJ = CORE_SRC / TPLJ

if not APP_TGZ.exists():
    print(f"there is no {APP_TGZ}")
    sys.exit(1)

with tarfile.open(APP_TGZ, mode="r:gz") as tf:
    CORE_TPLJ.write_bytes(tf.extractfile(f"package/build/{TPLJ}").read())

print(f"Extracted {TPLJ} to {CORE_SRC / TPLJ}")
