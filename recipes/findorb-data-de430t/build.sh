#!/bin/bash

set -e

DE_FN="linux_p1550p2650.430t"
EPH_PREFIX="$PREFIX/share/findorb/jpl_eph"

mkdir -p "$EPH_PREFIX"
(cd "$EPH_PREFIX" && curl -O "ftp://ssd.jpl.nasa.gov/pub/eph/planets/Linux/de430t/$DE_FN")
