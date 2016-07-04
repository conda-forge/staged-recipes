This is exactly the same recipe as:
    https://github.com/conda-forge/python-feedstock/commit/bbc8ed6f1a3d8d641f9c2d887afbcb81d5ff2a61

except that:
    - in `build.sh`, `./configure` is passed `--with-pydebug`.
    - in `bld.bat`, `build.bat` is passed `-d`.
    - in `meta.yaml`, `debug` feature is added.
