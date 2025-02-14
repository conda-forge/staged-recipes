#!/bin/bash
set -ex

conda activate root

make-program : --appdir "${PREFIX}/bin" --verbose

