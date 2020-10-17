#include <omp.h>
#include "mpi.h"
#include <stdio.h>
#define _NUM_THREADS 4
/*  Each MPI process spawns a distinct OpenMP
 *  master thread; so limit the number of MPI 
 *  processes to one per node
 */
int main(int argc, char *argv[]) {
	int numprocs,my_rank,c, iam, np;
	/* set number of threads to spawn */
	omp_set_num_threads(_NUM_THREADS);
	/* initialize MPI stuff */
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD,&my_rank);
	/* the following is a trivial parallel OpenMP* executed by each MPI process*/
	#pragma omp parallel reduction(+:c) private(iam)
	{
		np = omp_get_num_threads();
		iam = omp_get_thread_num();
		c = omp_get_num_threads();
		printf("Thread %d out of %d, process %d out of %d.\n", iam, np, my_rank, numprocs);
	}
	/* expect a number to get printed for each MPI process */
	printf("Process %d: c = %d\n",my_rank, c);
	/* finalize MPI */
	MPI_Finalize();
	return 0;
}