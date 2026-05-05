#!/bin/bash
set -ex

export ORT_LIB_LOCATION=$PREFIX
export ORT_PREFER_DYNAMIC_LINK=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
python -m pip install . --no-build-isolation -vv
