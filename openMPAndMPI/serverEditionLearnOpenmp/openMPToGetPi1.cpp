#include <iostream>
#include <cstdio>
#include <time.h>
#include <omp.h>
#include <stdlib.h>

int threadNum =56;
using namespace std;
int main(int argc,char * argv[]){
    if(argc >1){
        int threadNum = atoi(argv[1]);
        cout<<"already input value the thread num is "<<threadNum<<endl;
    }else{
        cout<<"no input value found!!!!!!,the default "<<threadNum<<endl;
    }
    double begin_time = omp_get_wtime();   //记录开始的时间
    double seconds;
    double dx = 10e-8;
    double sum = 0;
    int n = 1/dx;
    sum = 0;
    omp_set_num_threads(threadNum);
    #pragma omp  parallel  for reduction(+:sum)
    for(int i=0;i<n;i++){
        double xx = i*dx ;
        sum +=  1/(1 + xx*xx) * dx;
    }

    double end_time = omp_get_wtime();  //记录结束的时间

    seconds = end_time - begin_time;
    cout<<"cost time "<<seconds<<" seconds"<<endl; //将最终的消耗时间进行打印
    printf("%.16lf\n",4*sum);
}


/*
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

56个核心
no input value found!!!!!!,the default 56
cost time 0.0155015 seconds
3.1415927535897819


 * */