#!/bin/sh
set -e -x

cargo run --bin stub_gen --features hifitime,python

$PYTHON -m pip install ./ligo_hires_gps_time -vv
