from pathlib import Path
import shutil
import os

PKG_NAME = os.environ["PKG_NAME"]
SRC_DIR = Path(os.environ["SRC_DIR"])
RECIPE_DIR = Path(os.environ["RECIPE_DIR"])
PREFIX = Path(os.environ["PREFIX"])

ETC = PREFIX / "conda"
SCRIPTS = RECIPE_DIR / "scripts"

CACHE_NAME = "neuralcoref_cache"
SHARE = PREFIX / "share"
CACHE_PATH = SHARE / CACHE_NAME

MODEL_DIR = SRC_DIR / CACHE_NAME

SHARE.mkdir(exist_ok=True)

# actually copy
shutil.copytree(MODEL_DIR, CACHE_PATH)

# add the (de)activate scripts
for ext in ["bat", "sh"]:
    for change in ["activate", "deactivate"]:
        dest = ETC / f"{change}.d" / f"{PKG_NAME}_{change}.{ext}"
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(SCRIPTS / f"{change}.{ext}", dest)
