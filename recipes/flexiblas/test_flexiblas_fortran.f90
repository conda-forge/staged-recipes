program test_flexiblas_fortran
  implicit none
  integer :: info, lwork
  double precision :: alpha, beta
  double precision :: a(2,2), b(2,2), c(2,2)
  double precision :: svd_a(2,2), s(2), u(2,2), vt(2,2), work_query(1)
  double precision, allocatable :: work(:)

  alpha = 1.0d0
  beta = 0.0d0

  a = reshape((/1.0d0, 3.0d0, 2.0d0, 4.0d0/), (/2,2/))
  b = 0.0d0
  b(1,1) = 1.0d0
  b(2,2) = 1.0d0
  c = 0.0d0

  call dgemm('N', 'N', 2, 2, 2, alpha, a, 2, b, 2, beta, c, 2)

  if (abs(c(1,1)-1.0d0) > 1.0d-12 .or. abs(c(2,1)-3.0d0) > 1.0d-12 .or. &
      abs(c(1,2)-2.0d0) > 1.0d-12 .or. abs(c(2,2)-4.0d0) > 1.0d-12) then
    print *, 'DGEMM check failed'
    stop 1
  end if

  svd_a = reshape((/1.0d0, 3.0d0, 2.0d0, 4.0d0/), (/2,2/))
  lwork = -1
  call dgesvd('A', 'A', 2, 2, svd_a, 2, s, u, 2, vt, 2, work_query, lwork, info)
  if (info /= 0) then
    print *, 'DGESVD workspace query failed'
    stop 1
  end if

  lwork = int(work_query(1))
  if (lwork < 8) lwork = 8
  allocate(work(lwork))
  svd_a = reshape((/1.0d0, 3.0d0, 2.0d0, 4.0d0/), (/2,2/))
  call dgesvd('A', 'A', 2, 2, svd_a, 2, s, u, 2, vt, 2, work, lwork, info)
  deallocate(work)

  if (info /= 0 .or. s(1) <= 0.0d0 .or. s(2) <= 0.0d0) then
    print *, 'DGESVD check failed'
    stop 1
  end if

  print *, 'Fortran BLAS/LAPACK checks passed'
end program test_flexiblas_fortran
