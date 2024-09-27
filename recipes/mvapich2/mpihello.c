#include <mpi.h>
#include <stdio.h>  
#include <unistd.h>  

int main(int argc, char ⋆argv[])
{
    int rank;
    char hostname[256];

    MPI_Init(&argc, &argv);
    gethostname(hostname, 256);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    printf("rank %d on %s says hello!\n", rank, hostname);
    MPI_Finalize();
    return 0;
}
