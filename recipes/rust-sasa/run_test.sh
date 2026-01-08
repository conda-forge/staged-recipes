#!/bin/bash

set -exo pipefail

rust-sasa tests/data/pdbs/example.cif out.json

if [[ ! -f out.json ]]; then
  echo "File out.json does not exist"
  exit 1
fi

output=$(cat out.json)

expected='"value":220.10417,"name":"MET","is_polar":false'
if ! echo "$output" | grep -q "$expected"; then
  echo "Expected string '$expected' not found in output"
  exit 1
fi

echo "Test passed!"
