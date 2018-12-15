program maths
  use omp_lib
  implicit none

  real(8) :: x = 2.0_8
  complex :: z = (1.0, 2.0)
  integer,parameter :: n = 4567
  integer :: i
  real :: f(n)

  x = sqrt(x)
  z = sqrt(z)

  do i = 1, n
    f(i) = i
  enddo

  !$OMP PARALLEL SHARED(f) PRIVATE(i)

  !$omp master
  print *, "number of threads:",  omp_get_num_threads()
  !$omp end master

  !$OMP DO
  do i = 1, n
    f(i) = sqrt(f(i))
  enddo
  !$OMP END DO NOWAIT
  !$OMP END PARALLEL

  print *, "sqrt(2):", f(2)
end program maths
