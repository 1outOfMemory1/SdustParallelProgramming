#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<time.h>
#include<mpi.h>
#include <omp.h>

const long long int n = 100000000;      //共进行了n次独立重复试验

int NUM_THREADS =  0;     //开启的线程数

int main(int argc,char** argv){ 
    MPI_Init(NULL,NULL);//初始化
    for(NUM_THREADS=2;NUM_THREADS<=32;NUM_THREADS+=2)
  {    
     omp_set_num_threads(NUM_THREADS);
	 
     long long int t_circle = 0;       //对于每一个进程，落在它圆形区域中的点的总数,初始为0
     long long int all_circle = 0;     //把所有进程中，落在圆形区域中的总数加起来
	 
     int my_rank;                      //每一个进程都有一个对应的标号
     int thread_num;                   //总的进程数
   
     MPI_Comm_size(MPI_COMM_WORLD,&thread_num);    //得到进程总数
     MPI_Comm_rank(MPI_COMM_WORLD,&my_rank);       //得到进程编号
     long long int t_n=n/thread_num;            //每一个进程分担一部分实验量
	
	 srand(time(NULL));
	 
	 long long int i;
	 double begin_time = omp_get_wtime();   //记录开始的时间
	 #pragma omp parallel for reduction(+:t_circle)
	 for(i=0;i< t_n;i++){     
        double x=(double)rand()/(double)RAND_MAX;     //产生随机小数
        double y=(double)rand()/(double)RAND_MAX;     //没有必要生成复数，因为最后要平方
        double distance=x*x+y*y;
         if(distance<=1)
            t_circle++;
     }
	 double end_time = omp_get_wtime();  //记录结束的时间
	 
	 double startTime = MPI_Wtime();
     MPI_Reduce(&t_circle,&all_circle,1,MPI_LONG_LONG,MPI_SUM,0,MPI_COMM_WORLD);
	 double endTime = MPI_Wtime();
	 
     if(my_rank==0){
         double pi=(double)all_circle/(double)n*4;
		 printf("\n线程数：%d\n",NUM_THREADS);
         printf("the estimate value of pi is %f\n",pi);
		 printf("Cost time: %f s\n",endTime - startTime+end_time - begin_time);
     }	  
    }
	 MPI_Finalize();
     return 0;
 }