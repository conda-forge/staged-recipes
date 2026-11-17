"""Locate the build-platform Zig compiler, including Windows packages."""
import os
from pathlib import Path
import shutil


def zig_executable():
    # Windows conda packages provide a triplet-named executable, and may not
    # provide a bare zig.exe. Prefer the compiler selected by activation.
    for command in [os.environ.get('ZIG'), os.environ.get('CONDA_ZIG_BUILD'), 'zig']:
        if command:
            executable = shutil.which(command)
            if executable:
                return executable
    # Also handle build environments where activation did not export ZIG.
    build_prefix = os.environ.get('BUILD_PREFIX')
    if build_prefix:
        executable = Path(build_prefix) / 'Library/bin/x86_64-w64-mingw32-zig.exe'
        if executable.is_file():
            return str(executable)
    raise FileNotFoundError('Cannot find the build-platform Zig compiler; checked ZIG, CONDA_ZIG_BUILD, PATH, and BUILD_PREFIX')
