"""Install identical shell scripts for a noarch: python conda package."""

import os
import shutil
from pathlib import Path

prefix: Path = Path(os.environ["PREFIX"])
recipe: Path = Path(os.environ["RECIPE_DIR"])
script_dir: Path = recipe / "scripts"
helper_dst: Path = prefix / "etc" / "conda" / "imas-paraview-pvpath.py"
helper_dst.parent.mkdir(parents=True, exist_ok=True)
shutil.copyfile(script_dir / "imas-paraview-pvpath.py", helper_dst)
for action in ("activate", "deactivate"):
    folder = prefix / "etc" / "conda" / (action + ".d")
    folder.mkdir(parents=True, exist_ok=True)
    for ext in ("sh", "fish", "ps1", "bat"):
        shutil.copyfile(
            script_dir / f"{action}.{ext}", folder / f"imas-paraview-{action}.{ext}"
        )
