export FPM_FC=gfortran
export FPM_FFLAGS="-fbounds-check -ffree-line-length-0 -fimplicit-none -O3 -DWITH_QP=1"
fpm build

