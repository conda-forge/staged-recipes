#!/bin/bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rm "${script_dir}/mathjax-path" || exit 1
