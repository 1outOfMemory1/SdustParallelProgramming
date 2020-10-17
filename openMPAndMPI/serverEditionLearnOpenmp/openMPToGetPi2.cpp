#include <iostream>
#include <cstdlib>
#include <ctime>
#include <omp.h>
#include <cstdio>
using namespace std;
int threadNum = 3;
int TestNum = 100000000;


int main(int argc,char * argv[]){
    if(argc >1){
        int threadNum = atoi(argv[1]);
        cout<<"already input value the thread num is "<<threadNum<<endl;
    }else{
        cout<<"no input value found!!!!!!,the default "<<threadNum<<endl;
    }
    double begin_time = omp_get_wtime();   //记录开始的时间
    double seconds;
    srand(time(0));
    int inside = 0;
    omp_set_num_threads(threadNum);
    #pragma omp  parallel  for reduction(+:inside)
    for(int i = 0; i < TestNum; ++i) {
        double x = (double) rand() / RAND_MAX;
        double y = (double) rand() / RAND_MAX;
        if(x * x + y * y <= 1.0) ++inside;
    }
    double pi = 4.0 * inside / TestNum;
    printf("test cases is %d\n",TestNum);
    printf("PI = %.10lf\n",pi);
    double end_time = omp_get_wtime();  //记录结束的时间

    seconds = end_time - begin_time;
    cout<<"cost time "<<seconds<<" seconds"<<endl; //将最终的消耗时间进行打印
    return 0;
}

/*
 *
 *
1个核心  1亿随机数点
no input value found!!!!!!,the default 1
test cases is 100000000
PI = 3.1415272000
cost time 2.66854 seconds

3个核心  1亿随机数点
no input value found!!!!!!,the default 3
test cases is 100000000
PI = 3.1413612400
cost time 18.0389 seconds

6个核心  1亿随机数点
no input value found!!!!!!,the default 6
test cases is 100000000
PI = 3.1415436000
cost time 43.0076 seconds

16个核心  1亿随机数点
no input value found!!!!!!,the default 16
test cases is 100000000
PI = 3.1414892800
cost time 35.556 seconds

26个核心  1亿随机数点
no input value found!!!!!!,the default 26
test cases is 100000000
PI = 3.1414068400
cost time 36.8719 seconds

56个核心  1亿随机数点
no input value found!!!!!!,the default 56
test cases is 100000000
PI = 3.1416127200
cost time 37.4814 seconds

 */
