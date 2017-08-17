#!/bin/bash

echo running w3m help
w3m -help
echo $?
echo running grep help
grep --help

echo running test with grep
w3m -help | grep usage



