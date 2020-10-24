#include<cstdio>
#include <ctime>
#include <iostream>
#include <cstdlib>
#include <omp.h>
#include <mpi.h>
int threadNum = 2;
using namespace  std;
int main(int argc,char *argv[]){
    long long testNum = 100000000;  //TestNum 是测试数量
    long long insideCount = 0;   // 在圆中的次数
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
        printf("threadNum = %d\n",threadNum);
    }

    long long partInsideCount = 0;
    omp_set_num_threads(threadNum); // 设置并行的线程数有 3 个
    #pragma omp  parallel  for reduction(+:partInsideCount) // 告诉编译器要进行并行了 将每个i平均分配到合适的核心上边
    for(long long i = rank; i < testNum; i+=num_procs) {
        double x = (double) rand() / RAND_MAX;
        double y = (double) rand() / RAND_MAX;
	//        printf("rank = %d , x = %llf  y = %llf",rank,x,y);
        if(x * x + y * y <= 1.0) ++partInsideCount;
    }
	// 将每个进程算的数 汇总起来 得到 所有落在圆中的点的个数
    MPI_Reduce(&partInsideCount,&insideCount,1,MPI_LONG_LONG,MPI_SUM,0,MPI_COMM_WORLD);

    if(rank == 0){ // 打印pi 然后计算时间 输出执行时间
        printf("all test cases is %lld\n",testNum);
        printf("insideCount is %.lld\n",insideCount);
        printf("pi is %lf\n", 4.0 * insideCount / testNum);
        endTime = MPI_Wtime();
        printf("Time cost :%f s \n",endTime-startTime);
    }
    MPI_Finalize();
    return 0;
}
// mpirun -np 6  ./mpiToGetPi

/*

1个核心  一亿随机数点
mpirun -np 1  ./hybridMpiAndOpenMPToGetPi2
total 1 processes
all test cases is 100000000
insideCount is 78536091
pi is 3.141444
Time cost :38.680065 s

6个核心  一亿随机数点
mpirun -np 6  ./hybridMpiAndOpenMPToGetPi2
total 6 processes
all test cases is 100000000
insideCount is 78549052
pi is 3.141962
Time cost :6.447433 s

16个核心  一亿随机数点
mpirun -np 16  ./hybridMpiAndOpenMPToGetPi2
total 16 processes
all test cases is 100000000
insideCount is 78542143
pi is 3.141686
Time cost :2.329494 s

26个核心  一亿随机数点
mpirun -np 26  ./hybridMpiAndOpenMPToGetPi2
total 26 processes
all test cases is 100000000
insideCount is 78522274
pi is 3.140891
Time cost :1.382525 s


36个核心  一亿随机数点
mpirun -np 36  ./hybridMpiAndOpenMPToGetPi2
total 36 processes
all test cases is 100000000
insideCount is 78571044
pi is 3.142842
Time cost :1.067266 s

56个核心  一亿随机数点
mpirun -np 56  ./hybridMpiAndOpenMPToGetPi2
total 56 processes
all test cases is 100000000
insideCount is 78534928
pi is 3.141397
Time cost :1.050506 s

1000亿随机数点 56个核心
all test cases is 100000000000
insideCount is 78538636803
pi is 3.141545
Time cost :545.349332 s


200亿随机数点 56个核心
all test cases is 20000000000
insideCount is 15707720235
pi is 3.141544
Time cost :123.705240 s

20亿随机数点 56个核心
all test cases is 2000000000
insideCount is 1570558530
pi is 3.141117
Time cost :15.297532 s

*/