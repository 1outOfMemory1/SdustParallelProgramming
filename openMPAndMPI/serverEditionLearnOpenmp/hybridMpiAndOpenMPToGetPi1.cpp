#include<stdio.h>
#include<mpi.h>
#include <iostream>
using namespace  std;
int main(int argc,char *argv[]){
    int rank,num_procs;  // rank 是当前运行线程编号  proc_len 是进程名字长度  num_procs 是进程数量
    double startTime = 0,endTime = 0; //记录时间
    double dx = 10e-8;
    double n = 1/dx;
    int nn = n;
    int i ;

    double pi = 0;
    MPI_Init(&argc,&argv);
    //用来获取正在调用进程的通信子中的进程号的函数
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    //用来得到通信子的进程数的函数
    MPI_Comm_size(MPI_COMM_WORLD,&num_procs);
    //mpi接口获取进程名 int MPI_Get_processor_name(char *name,int *resultlen)
//    printf("current process is %d,total %d processes\n",rank,num_procs);
    if(rank == 0){  // 开始计时
        startTime = MPI_Wtime();
        printf("total %d processes\n",num_procs);
    }
    double partSum = 0;
    double partPi = 0;
    // 每一个进程 比如 有10个核  那么 0 10 20 30 .. 的sum归 0 号进程所算
    #pragma omp  parallel  for  reduction(+:partSum)
    for(i = rank;i<nn;i+=num_procs){
        double xx =dx * i;
        partSum  += 4.0/(1.0+xx*xx) ;
    }

    partPi = partSum*dx;
    MPI_Reduce(&partPi,&pi,1,MPI_DOUBLE,MPI_SUM,0,MPI_COMM_WORLD);
    if(rank == 0){ // 打印pi 然后计算时间 输出执行时间
        printf("PI is %.20f\n",pi);
        endTime = MPI_Wtime();
        printf("Time cost :%f s \n",endTime-startTime);
    }
    MPI_Finalize();
    return 0;
}
// mpirun -np 1  ./hybridMpiAndOpenMPToGetPi1
/*
一个核心
mpirun -np 1  ./hybridMpiAndOpenMPToGetPi1
total 1 processes
PI is 3.14159275358978495873
Time cost :0.013203 s

六个核心
mpirun -np 6  ./hybridMpiAndOpenMPToGetPi1
total 6 processes
PI is 3.14159275358979117598
Time cost :0.052505 s

十六个核心
mpirun -np 16  ./hybridMpiAndOpenMPToGetPi1
total 16 processes
PI is 3.14159275358979117598
Time cost :0.107382 s

五十六个核心
mpirun -np 56  ./hybridMpiAndOpenMPToGetPi1
total 56 processes
PI is 3.14159275358979117598
Time cost :0.382000 s
*/