#!/bin/bash
set -ex

# Drop the ``Priority`` field if CRAN set one (e.g. "recommended"); conda's
# R-package layout doesn't use it and ``R CMD INSTALL`` warns otherwise.
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .
