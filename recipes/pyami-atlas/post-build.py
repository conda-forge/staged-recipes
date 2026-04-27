import os, shutil, site

sp = site.getsitepackages()[0]

src = os.path.join(sp, "pyAMI_atlas")
dst = os.path.join(sp, "pyAMI", "atlas")

if os.path.exists(dst):
    shutil.rmtree(dst)

shutil.copytree(src, dst)
