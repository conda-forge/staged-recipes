#!/bin/bash
set -e

export LD_LIBRARY_PATH=$PREFIX/metis-aster/lib
$PREFIX/metis-aster/bin/mpmetis graphs/metis.mesh 10
$PREFIX/metis-aster/bin/gpmetis graphs/mdual.graph 10
$PREFIX/metis-aster/bin/ndmetis graphs/mdual.graph 10
$PREFIX/metis-aster/bin/gpmetis graphs/test.mgraph 10
$PREFIX/metis-aster/bin/m2gmetis graphs/metis.mesh 10