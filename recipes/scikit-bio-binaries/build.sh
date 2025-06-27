#!/bin/bash

echo "=== make all ==="
make all
if [ $? -ne 0 ]
then
  echo "ERROR: Build failed"
  exit 1
fi
echo "INFO: Build and install succeeded"

echo "=== Internal tests ==="
make test
if [ $? -ne 0 ]
then
  echo "ERROR: tests failed"
  exit 1
fi
echo "INFO: Tests succeeded"
