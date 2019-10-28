#!/bin/bash

if [ ! -e "${PREFIX}/lib/libaatm.${SHLIB_EXT}"]; then
    exit 1
fi
