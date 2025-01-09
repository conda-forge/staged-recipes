
MAKE ?= make
AR ?= $(AR)
SRC_LIBXC ?= libxcifc_stub.f90
SRC_MPI ?= mpi_stub.f90
SRC_MKL ?= mkl_stub.f90
SRC_W90S ?= w90_stub.f90
SRC_FFT ?= zfftifc_fftw.f90 cfftifc_fftw.f90
F90 ?= $(F90)
F90_OPTS ?= -Ofast -march=native -mtune=native -fopenmp -ffpe-summary=none -Wno-lto-type-mismatch
F90_LIB ?= -lblas -llapack -lfftw3 -lfftw3f $(LDFLAGS)
