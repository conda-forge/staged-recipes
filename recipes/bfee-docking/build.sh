#!/usr/bin/env bash
set -ex

rm -f bfee_docking/third_party/vina/vina.exe
rm -f bfee_docking/third_party/smina/smina.exe
find bfee_docking/third_party -type f \( -name "*.dll" -o -name "*.bat" -o -name "*.jar" \) -delete
rm -rf bfee_docking/third_party/obabel

chmod +x bfee_docking/third_party/vina/vina
chmod +x bfee_docking/third_party/smina/smina

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
