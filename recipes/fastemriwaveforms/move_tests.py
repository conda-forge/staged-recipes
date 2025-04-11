import os
import pathlib
import shutil

src_dir = pathlib.Path(os.getenv("SRC_DIR"))
prefix = pathlib.Path(os.getenv("PREFIX"))

shutil.copytree(src_dir / "tests", prefix / "few" / "tests")
