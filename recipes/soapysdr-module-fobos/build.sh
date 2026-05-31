#!/usr/bin/env bash
set -euo pipefail

echo "The conda-forge style split recipe is currently Windows/Radioconda-only."
echo "Enable Linux/macOS only after validating udev rules, install paths,"
echo "runtime library search paths and SoapySDR module discovery."
exit 1
