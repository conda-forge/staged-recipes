#!/bin/sh
set -euo pipefail

fpm build #--profile release --flag "-DREAL32"
