#!/usr/bin/env bash

set -ex

DEBUG_MODE=true ./setup.sh --build-type Release --prefix="$PREFIX" --install
