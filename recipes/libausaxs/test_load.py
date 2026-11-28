"""Load libausaxs through ctypes the way pyausaxs does and check the C API is exported."""
import ctypes
import os
import sys
from pathlib import Path

prefix = Path(os.environ["PREFIX"])
if sys.platform == "win32":
    lib = prefix / "Library" / "bin" / "ausaxs.dll"
elif sys.platform == "darwin":
    lib = prefix / "lib" / "libausaxs.dylib"
else:
    lib = prefix / "lib" / "libausaxs.so"

assert lib.is_file(), f"missing {lib}"
handle = ctypes.CDLL(str(lib))
# entry points used by pyausaxs.signatures
for symbol in ("test_integration", "get_last_error_msg", "deallocate"):
    assert hasattr(handle, symbol), f"{symbol} not exported by {lib.name}"
print(f"loaded {lib}")
