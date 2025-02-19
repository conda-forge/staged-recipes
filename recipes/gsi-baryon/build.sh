#!/usr/bin/env bash

set -ex

./setup.sh --build-type Release --prefix="$PREFIX" --install
