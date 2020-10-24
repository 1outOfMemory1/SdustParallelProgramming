#include <iostream>
#include <cstdlib>
#include <ctime>
#include <omp.h>
#include <cstdio>
using namespace std;
int threadNum = 10;
int TestNum = 100;

int main(int argc,char * argv[]){
    if(argc >1){
        int threadNum = atoi(argv[1]);
        cout<<"already input value the thread num is "<<threadNum<<endl;
    }else{
        cout<<"no input value found!!!!!!,the default "<<threadNum<<endl;
    }
    double begin_time = omp_get_wtime();   //记录开始的时间
    double seconds;
    unsigned  int seed =10;
    int inside = 0;
    omp_set_num_threads(threadNum);    // 设置并行的线程数有 threadNum 个
    #pragma omp  parallel  for reduction(+:inside)
    for(int i = 0; i < TestNum; ++i) {
        // 随机获得 x 和 y 的值 均小于1
        double x = (double) rand_r(&seed) / RAND_MAX;
        double y = (double) rand_r(&seed) / RAND_MAX;
        // 如果距离原点距离小于=1 那么这个点就算在在圆中
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
 有个小问题 服务器上会出现负优化的情况 本机测试情况都正常  不知道是那个地方出现问题
 *
 *

服务器上
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

/* 本机上
一个核心 1亿随机数点
no input value found!!!!!!,the default 1
test cases is 100000000
PI = 3.1415616000
cost time 3.052 seconds

两个核心 1亿随机数点
no input value found!!!!!!,the default 2
test cases is 100000000
PI = 3.1415646000
cost time 1.586 seconds

四个核心 1亿随机数点
no input value found!!!!!!,the default 4
test cases is 100000000
PI = 3.1412051600
cost time 0.814 seconds

六个核心 1亿随机数点
no input value found!!!!!!,the default 6
test cases is 100000000
PI = 3.1410563600
cost time 0.661 seconds
 *
 */
