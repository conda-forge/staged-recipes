import os
import shutil
from pathlib import Path

PREFIX = Path(os.environ["PREFIX"])
SRC_DIR = Path(os.environ["SRC_DIR"])
CONF = SRC_DIR / "jupyterlab_github.json"
CONF_DIR = PREFIX / "etc/jupyter/jupyter_notebook_config.d"

CONF_DIR.mkdir(parents=True)

shutil.copy2(CONF, CONF_DIR / CONF.name)
