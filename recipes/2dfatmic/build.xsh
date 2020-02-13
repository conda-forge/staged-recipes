#!/usr/bin/env xonsh
from xonsh.lib.os import indir

mkdir -p build
mkdir -p $PREFIX/bin
with indir("build"):
    for f in g`../*.f`:
        if "main" in f:
            main = f
            continue
        ![$FC -c @(f)]
    ![$FC @(main) *.o -o 2dfatmic]
    ![cp 2dfatmic $PREFIX/bin/2dfatmic]
