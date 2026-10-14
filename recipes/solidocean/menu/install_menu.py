"""Install the desktop shortcut (menuinst) into $PREFIX/Menu: its definition and icons (png, icns, ico).

Run from the source directory during the build; Python, so the same on every platform."""

import os
import shutil
from pathlib import Path

from PIL import Image

menu = Path(os.environ["PREFIX"]) / "Menu"
menu.mkdir(parents=True, exist_ok=True)
shutil.copy(Path(__file__).parent / "solidocean.json", menu)
im = Image.open(Path("src/solidocean/gui/resources/icon.png")).convert("RGBA")
im.resize((256, 256), Image.LANCZOS).save(menu / "solidocean.png")
im.save(menu / "solidocean.icns")
im.save(menu / "solidocean.ico", sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
