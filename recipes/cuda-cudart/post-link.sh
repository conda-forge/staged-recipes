#!/bin/bash

[[ -d "$PREFIX/lib/pkgconfig" ]] && sed -E -i "s|cudaroot=.+|cudaroot=$PREFIX|g" $PREFIX/lib/pkgconfig/cuda*.pc

exit 0
