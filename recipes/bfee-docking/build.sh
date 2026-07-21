#!/usr/bin/env bash
set -ex

find bfee_docking/third_party/vina -type f ! -name "vina" -delete
find bfee_docking/third_party/smina -type f ! -name "smina" -delete
rm -rf bfee_docking/third_party/obabel

chmod +x bfee_docking/third_party/vina/vina
chmod +x bfee_docking/third_party/smina/smina

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
