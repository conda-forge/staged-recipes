#!/bin/sh

set -e

export PMIP_CBC_LIBRARY=$PREFIX
python -m pip install . -vv
