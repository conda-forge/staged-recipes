#!/usr/bin/env bash

stride pdb1fmc.pdb > pdb1fmc_stride.out

CMP=$(cmp pdb1fmc_stride.out pdb1fmc.out)

if [ "$CMP" ]; then
    echo "ERROR: STRIDE output of pdb1fmc.pdb does not match expected pdb1fmc.out"
    exit 1
