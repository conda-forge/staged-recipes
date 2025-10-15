#!/usr/bin/env bash
# remove only the exact entry we added
export PATH=$(echo "$PATH" | sed -e "s;$CONDA_PREFIX/share/dcm4che/bin:;;")
