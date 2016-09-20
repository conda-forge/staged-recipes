#!/bin/bash

# Stop on first error
set -e

hyperion_amr amr.rtin amr.rtout
hyperion_car car.rtin car.rtout
hyperion_cyl cyl.rtin cyl.rtout
hyperion_oct oct.rtin oct.rtout
hyperion_sph sph.rtin sph.rtout
hyperion_vor vor.rtin vor.rtout

# Parallel tests don't work well on CI services
# mpirun -n 4 hyperion_amr_mpi amr.rtin amr_mpi.rtout
# mpirun -n 4 hyperion_car_mpi car.rtin car_mpi.rtout
# mpirun -n 4 hyperion_cyl_mpi cyl.rtin cyl_mpi.rtout
# mpirun -n 4 hyperion_oct_mpi oct.rtin oct_mpi.rtout
# mpirun -n 4 hyperion_sph_mpi sph.rtin sph_mpi.rtout
# mpirun -n 4 hyperion_vor_mpi vor.rtin vor_mpi.rtout
