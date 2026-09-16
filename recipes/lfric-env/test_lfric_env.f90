! The central check for the whole environment.
!
! gfortran can only read .mod files written by its own generation, so compiling
! this one program proves that conda-forge's Fortran stack (mpich, netcdf-fortran)
! and every Fortran-module-shipping package built alongside this recipe (xios,
! yaxt, shumlib) agree on a single compiler -- the one risk that a per-package
! build check cannot catch, because each package is only ever checked against
! itself.
!
! `use yaxt` reaches the 64-bit-Xt_int build specifically, since that is the yaxt
! this environment pins (see the recipe header).
!
! -fsyntax-only is enough: this is a module-ABI check, not a link check.
program test_lfric_env
  use mpi
  use netcdf
  use xios
  use yaxt
  use f_shum_string_conv_mod
  implicit none
end program test_lfric_env
