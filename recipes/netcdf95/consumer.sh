#!/usr/bin/env bash
set -euxo pipefail

"${FC}" --version
cd Tests
"${FC}" -I"${PREFIX}/include" test_netcdf95.f90 -L"${PREFIX}/lib" \
  -Wl,-rpath,"${PREFIX}/lib" -lnetcdf95 -o test_netcdf95
./test_netcdf95
