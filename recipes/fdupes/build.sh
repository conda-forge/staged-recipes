#!/usr/bin/env bash
make fdupes
make PREFIX="$CONDA_PREFIX" install
