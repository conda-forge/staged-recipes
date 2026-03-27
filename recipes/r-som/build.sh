#!/bin/bash
export DISABLE_AUTOBREW=1

# Prevent ~/.R/Makevars from overriding the conda r-base Makeconf.
# R's Makeconf (installed with r-base) already has the correct conda
# compiler wrapper and CXXFLAGS; user Makevars interfere with this.
export R_MAKEVARS_USER=/dev/null

${R} CMD INSTALL --build . ${R_ARGS}
