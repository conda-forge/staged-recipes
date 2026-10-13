"""Write the shortcut icons (png, icns, ico) for menuinst from the GUI icon."""

import sys
from pathlib import Path

from PIL import Image

src, out = Path(sys.argv[1]), Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)
im = Image.open(src).convert("RGBA")
im.resize((256, 256), Image.LANCZOS).save(out / "solidocean.png")
im.save(out / "solidocean.icns")
im.save(out / "solidocean.ico", sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
