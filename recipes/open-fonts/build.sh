#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir -p "$PREFIX/fonts"
mv open-fonts "$PREFIX/fonts/"
