#include<cstdio>
#include <ctime>
#include<mpi.h>
#include <iostream>
#include <cstdlib>

using namespace  std;
int main(int argc,char *argv[]){
    int testNum = 100000000;  //TestNum 是测试数量
    int insideCount = 0;   // 在圆中的次数
    int rank,num_procs;  // rank 是当前运行线程编号  proc_len 是进程名字长度  num_procs 是进程数量
    double startTime = 0,endTime = 0; //记录时间
    srand(time(0));
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
    int partInsideCount = 0;
    for(int i = rank; i < testNum; i+=num_procs) {
        double x = (double) rand() / RAND_MAX;
        double y = (double) rand() / RAND_MAX;
        if(x * x + y * y <= 1.0) ++partInsideCount;
    }

    MPI_Reduce(&partInsideCount,&insideCount,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);

    if(rank == 0){ // 打印pi 然后计算时间 输出执行时间
        printf("all test cases is %.d\n",testNum);
        printf("insideCount is %.d\n",insideCount);
        printf("pi is %lf\n", 4.0 * insideCount / testNum);
        endTime = MPI_Wtime();
        printf("Time cost :%f s \n",endTime-startTime);
    }
    MPI_Finalize();
    return 0;

}
// mpirun -np 6  ./mpiToGetPi

/*
一个核心  1亿随机数点
mpirun -np 1  ./mpiToGetPi2
total 1 processes
all test cases is 100000000
insideCount is 78535676
pi is 3.141427
Time cost :2.711076 s

六个核心  1亿随机数点
mpirun -np 6  ./mpiToGetPi2
total 6 processes
all test cases is 100000000
insideCount is 78552238
pi is 3.142090
Time cost :0.467416 s

十六个核心  1亿随机数点
mpirun -np 16  ./mpiToGetPi2
total 16 processes
all test cases is 100000000
insideCount is 78536144
pi is 3.141446
Time cost :0.224380 s

二十六个核心  1亿随机数点
mpirun -np 26  ./mpiToGetPi2
total 26 processes
all test cases is 100000000
insideCount is 78553432
pi is 3.142137
Time cost :0.127888 s

三十六个核心 1亿随机数点
mpirun -np 36  ./mpiToGetPi2
total 36 processes
all test cases is 100000000
insideCount is 78577048
pi is 3.143082
Time cost :0.105607 s

五十六个核心 1亿随机数点
mpirun -np 56  ./mpiToGetPi2
total 56 processes
all test cases is 100000000
insideCount is 78529208
pi is 3.141168
Time cost :0.154462 s

*/