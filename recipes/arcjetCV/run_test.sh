#!/bin/bash
set -e  # exit when any command fails

echo "Testing arcjetCV GUI"
arcjetCV &
pkill arcjetCV
