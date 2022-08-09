#!/bin/sh
set -euo pipefail

pwd
echo $PWD
echo $SRC_DIR
ls
fpm build #--profile release --flag "-DREAL32"
