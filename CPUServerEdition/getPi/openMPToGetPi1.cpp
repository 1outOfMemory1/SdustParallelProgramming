#include <iostream>
#include <cstdio>
#include <time.h>
#include <omp.h>
#include <math.h>
#include <stdlib.h>

int threadNum =36;   // 全局变量 记录并行的线程数目
using namespace std;
int main(int argc,char * argv[]){

    double seconds;  // 记录花费时间
    double sum = 0;   // 积分中每个小矩形面积的累加值
    int n = 1000000000;   // 将0 到 1 分成多少份
    double dx = 1.0/n;  // 积分中 dx的值

    sum = 0;

    for(int i=1;i<=7;i++){
        n = n/10;
        dx = 1.0/n;
        sum = 0;
        double begin_time = omp_get_wtime();   //记录开始的时间
        printf("n is  %d \n",n );
        #pragma omp  parallel  for reduction(+:sum)  // 告诉编译器要进行并行了 将每个i平均分配到合适的核心上边
        // reduction 是防止 sum值这个临界资源发生数据丢失
        for(int i=0;i<n;i++){
            double xx = i*dx ;
            sum +=  1/(1 + xx*xx) * dx; // 将每个小矩阵的面积累加起来得到最终的值就是积分的值
        }

        double end_time = omp_get_wtime();  //记录结束的时间
        seconds = end_time - begin_time;
        cout<<"cost time "<<seconds<<" seconds"<<endl; //将最终的消耗时间进行打印
        printf("%.16lf\n\n",4*sum);  // 输出pi的值
    }


}


/*
有优化效果 26个核心的时候是最优时间
 *

1个核心
no input value found!!!!!!,the default 1
cost time 0.140474 seconds
3.1415927535898853

6个核心
no input value found!!!!!!,the default 6
cost time 0.0444239 seconds
3.1415927535897130

16个核心
no input value found!!!!!!,the default 16
cost time 0.0202596 seconds
3.1415927535898223

26个核心
no input value found!!!!!!,the default 26
cost time 0.013228 seconds
3.1415927535897965


36个核心
no input value found!!!!!!,the default 36
cost time 0.0870785 seconds
3.1415927535897907



56个核心
no input value found!!!!!!,the default 56
cost time 0.0155015 seconds
3.1415927535897819


 * */