#!/bin/bash

echo running w3m
w3m
echo $?
echo running test with grap
w3m 2>&1 | grep usage

