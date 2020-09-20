#include "SerialMatrixMultiply.h"
#include <time.h>
#include <iostream>

using namespace std;
int main(int argc,char * argv[]){
    int a = atoi(argv[1]); //读取执行时参数 并把它转换为int值 这个值代表矩阵大小 size * size 大小的两个矩阵相乘
    cout<<a<<endl;   // 把size打印出来
    double seconds;  //定义double类型的秒数  用于串行记录执行矩阵相乘前后的时间差
    SerialMatrixMultiply *m = new SerialMatrixMultiply(a);  //新建一个类 将a 也就是矩阵的规模填进去
    clock_t begin_time = clock();   //记录开始的时间
    m->multiply();  //执行矩阵的乘法
    clock_t end_time = clock();  //记录结束的时间
    seconds = ((double)end_time - begin_time) / CLOCKS_PER_SEC; //这个CLOCKS_PER_SEC 在不同的操作系统的值不一样 最终算出来的单位是秒
    cout<<"cost time "<<seconds<<" seconds"<<endl; //将最终的消耗时间进行打印
}