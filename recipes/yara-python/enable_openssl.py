"""Turn on yara-python's OpenSSL-backed features against conda-forge's openssl.

yara-python reads its build options from the (already present) [build_ext]
section of setup.cfg, so set them there rather than appending a new section.
"""
import configparser
import os
import sys

prefix = os.environ["PREFIX"]
if sys.platform == "win32":
    include_dir = os.path.join(prefix, "Library", "include")
    library_dir = os.path.join(prefix, "Library", "lib")
else:
    include_dir = os.path.join(prefix, "include")
    library_dir = os.path.join(prefix, "lib")

cfg = configparser.ConfigParser()
cfg.read("setup.cfg")
if not cfg.has_section("build_ext"):
    cfg.add_section("build_ext")
cfg["build_ext"]["enable_openssl"] = "1"
cfg["build_ext"]["include_dirs"] = include_dir
cfg["build_ext"]["library_dirs"] = library_dir
with open("setup.cfg", "w") as fh:
    cfg.write(fh)
print(dict(cfg["build_ext"]))
