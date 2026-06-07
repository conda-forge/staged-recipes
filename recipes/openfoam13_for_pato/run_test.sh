#!/bin/bash
set -e
echo "Testing openfoam13_for_pato..."
blockMesh -help > /dev/null
checkMesh -help > /dev/null
echo "OpenFOAM 13 for PATO: OK"
