#!/bin/bash

JULIA_HOME="$(dirname "${BASH_SOURCE[0]}")"

# Set JULIA_PKGDIR to $PREFIX/share/julia/site to avoid contaminating
# user's ~/.julia/.  This script will modify Pkg.dir() and
# Base.LOAD_CACHE_PATH[1] appropriately.  Note that wrapper script is
# used rather than /etc/julia/juliarc.jl because LOAD_CACHE_PATH is
# configured in base/sysimg.jl which is loaded before juliarc.jl.
if [ -z ${JULIA_PKGDIR+x} ] # see: http://stackoverflow.com/a/13864829
then
    JULIA_PKGDIR="$(dirname "$JULIA_HOME")/share/julia/site"
    export JULIA_PKGDIR
fi

# Set JULIA_HISTORY to $PREFIX/.julia_history to avoid saving
# to user's $HOME
if [ -z ${JULIA_HISTORY+x} ]
then
    JULIA_HISTORY="$(dirname "$JULIA_HOME")/.julia_history"
    export JULIA_HISTORY
fi

exec "$JULIA_HOME/julia_" "$@"
