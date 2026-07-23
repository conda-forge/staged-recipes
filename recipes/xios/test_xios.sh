#!/usr/bin/env bash
set -euxo pipefail

# The package_contents test already asserts the library, module and server
# binary exist. This checks the server binary is actually runnable -- i.e. that
# it resolves its MPI, netCDF and HDF5 shared libraries at run time, which is
# the failure mode a file-existence check cannot catch.
#
# xios_server.exe expects to be launched as part of an MPI job with a client, so
# it is not run standalone; --help is not offered either. Inspecting its dynamic
# dependencies is enough to prove every NEEDED library resolves.
exe="${PREFIX}/bin/xios_server.exe"
if command -v ldd >/dev/null 2>&1; then
  # linux: ldd resolves NEEDED libs; "not found" flags a missing dependency.
  ldd "$exe"
  if ldd "$exe" | grep -q "not found"; then
    echo "ERROR: xios_server.exe has unresolved shared libraries" >&2
    exit 1
  fi
elif command -v otool >/dev/null 2>&1; then
  # macOS has no ldd; otool -L lists the linked dylibs. Informational -- the
  # strict unresolved-dependency gate runs on linux (the production platform).
  otool -L "$exe"
fi

echo "XIOS_TEST_OK"
