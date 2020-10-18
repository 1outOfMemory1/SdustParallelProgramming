//由高数里的知识可知，根据上述公式可以求得pi/4。
#include<stdio.h>
#include<mpi.h>
#include <iostream>
using namespace  std;
int main(int argc,char *argv[]){
    int arr[3],i,rank;
//    cout<<"value number is "<<argc<<", they are"<<endl;
//    for(int i=0;i<argc;i++){
//        cout<<argv[i]<<" ";
//    }
//    cout<<endl;

    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    if(rank == 0){
        for(int i=0;i<3;i++){
            arr[i] = i + 1;
        }
    }
    MPI_Bcast(arr,3,MPI_INT,0,MPI_COMM_WORLD);
    printf("Process %d receives: " , rank);
    for(int i=0;i<3;i++)
        printf("%d ",arr[i]);
    printf("\n");
    MPI_Finalize();
    return 0;

}
// mpirun -np 6  ./mpiToGetPi