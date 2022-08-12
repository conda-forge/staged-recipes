#!/bin/sh
set -euo pipefail

pwd
echo $PWD


${FC} -c src/linear_interpolation_module.F90
${AR} crv linear_interpolation_module.a linear_interpolation_module.o

mv linear_interpolation_module.a   ${PREFIX}/lib/
mv linear_interpolation_module.mod ${PREFIX}/include/
