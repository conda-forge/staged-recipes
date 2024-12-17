program hello_world_mpi
  use mpi
  implicit none

  integer :: rank, size, ierr

  ! Initialize MPI
  call MPI_Init(ierr)

  ! Get the number of processes
  call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

  ! Get the rank of the process
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)

  ! Print hello world message
  print *, 'Hello, World! from process ', rank, ' out of ', size

  ! Finalize MPI
  call MPI_Finalize(ierr)

end program hello_world_mpi
