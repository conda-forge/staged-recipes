import ctypes
import os
import pathlib
import sys
import subprocess

from nccl._extensions.bindings._internal import nccl_ep, nccl_m2n

os.environ["CONDA_PREFIX"] = "/nonexistent"
prefix = pathlib.Path(sys.prefix)
assert pathlib.Path(nccl_ep._resolve_library_path()) == prefix / 'lib/libnccl_ep.so.0'
assert str(prefix / 'lib/libnccl_m2n.so') in nccl_m2n._candidate_library_paths()
# Verify actual ELF dependencies; imports alone do not load these libraries.
# Loading them also needs a GPU driver, which is unavailable on CI workers.
for library in ('libnccl_ep.so.0', 'libnccl_m2n.so'):
    dynamic = subprocess.check_output(['readelf', '-d', str(prefix / 'lib' / library)], text=True)
    assert '(NEEDED)' in dynamic and 'libcudart.so.' in dynamic, dynamic
    assert 'libnccl.so.2' in dynamic, dynamic
# M2N has no direct driver dependency, so test its relocated dlopen on CI too.
assert ctypes.CDLL(str(prefix / 'lib/libnccl_m2n.so')).ncclM2nInit
config = (prefix / 'include/nccl_ep/config.h').read_text()
assert str(prefix / 'include/nccl_ep') in config
assert str(prefix / 'include') in config
assert str(prefix / 'bin/nvcc') in config
assert '/work/' not in config
for module in ('ep', 'm2n'):
    package = prefix / f'lib/python{sys.version_info.major}.{sys.version_info.minor}/site-packages/nccl/{module}'
    assert not (package / 'lib').exists()
    assert not (package / 'include').exists()

# The JIT paths are compiled into the native library as well as config.h.
ep_binary = (prefix / 'lib/libnccl_ep.so.0').read_bytes()
for relative in ('include/nccl_ep', 'targets', 'bin/nvcc'):
    assert str(prefix / relative).encode() in ep_binary, relative
