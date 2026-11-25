import os
import sys
from pathlib import Path

import espeakng_loader

prefix = Path(os.environ.get("PREFIX") or os.environ.get("CONDA_PREFIX") or sys.prefix).resolve()
print("prefix:", prefix)
lib = Path(espeakng_loader.get_library_path()).resolve()
data = Path(espeakng_loader.get_data_path()).resolve()

assert lib.is_file(), lib
assert data.is_dir(), data
assert prefix in lib.parents, (prefix, lib)
assert prefix in data.parents, (prefix, data)
assert (data / "phontab").is_file()
assert (data / "en_dict").is_file()

lib_handle = espeakng_loader.load_library()
assert lib_handle is not None

# Initialize the library against the data directory and query its version.
import ctypes

lib_handle.espeak_Initialize.restype = ctypes.c_int
sample_rate = lib_handle.espeak_Initialize(2, 0, str(data.parent).encode(), 0)  # AUDIO_OUTPUT_SYNCHRONOUS
assert sample_rate > 0, sample_rate
lib_handle.espeak_Info.restype = ctypes.c_char_p
print("espeak-ng", lib_handle.espeak_Info(None).decode())
