import os
import shutil

prefix = os.environ["PREFIX"]

src_license = os.path.join("src", "LICENSE")
shutil.copy2(src_license, "LICENSE")

for name in ("bin", "lib", "meta", "share"):
    dst = os.path.join(prefix, name)
    shutil.copytree(name, dst, dirs_exist_ok=True)
