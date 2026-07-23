program test_shumlib
  ! f_shum_string_conv_mod is a base module (shum_byteswap USEs it), so it has no
  ! intra-shumlib dependencies to satisfy -- a clean target for the .mod ABI check.
  use f_shum_string_conv_mod
  implicit none
end program test_shumlib
