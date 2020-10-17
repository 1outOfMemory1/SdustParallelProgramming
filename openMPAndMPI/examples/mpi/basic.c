#include <stdio.h>
#include "mpi.h"
int main(int argc, char **argv){
  MPI_Comm comm = MPI_COMM_WORLD;
  int size, rank;
  MPI_Init(&argc, &argv);
  MPI_Comm_size(comm, &size);
  MPI_Comm_rank(comm, &rank);
  printf("This is process %d of %d processes.\n", rank, size);
  MPI_Finalize();
  return 0;
}
