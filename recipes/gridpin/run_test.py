"""Exercise the compiled engine without a country file (the files are hundreds of MB).

Opening a sheet goes through the Rust index reader; a missing file and a file that is not a
sheet must both come back as an ordinary Python OSError, not a crash.
"""
import os
import tempfile

import gridpin

work = tempfile.mkdtemp()

missing = os.path.join(work, "missing.bin")
try:
    gridpin.Geocoder(missing)
except OSError as exc:
    print("missing file:", exc)
else:
    raise SystemExit("gridpin.Geocoder accepted a file that does not exist")

junk = os.path.join(work, "junk.bin")
with open(junk, "wb") as f:
    f.write(b"this is not a gridpin sheet\n" * 4096)
try:
    gridpin.Geocoder(junk)
except OSError as exc:
    print("not a sheet:", exc)
else:
    raise SystemExit("gridpin.Geocoder accepted a file that is not a sheet")
