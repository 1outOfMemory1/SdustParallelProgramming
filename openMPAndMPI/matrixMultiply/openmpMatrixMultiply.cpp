#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cstdio>
#include <stdlib.h>
#include <omp.h>

using namespace std;

// 矩阵相乘 肯定是 m * n  乘以  n * p
long long  m=1000,n=2000,p=3000;
long long mn = m * n;
long long np = n * p;
long long mp = m * p;
int main(int argc,char * argv[]) {
    if(argc >1){
        int a = atoi(argv[1]); //读取执行时参数 并把它转换为int值 这个值代表矩阵大小 size * size 大小的两个矩阵相乘
        cout<<"已输入参数 矩阵规模为 "<<m<<"*"<<n<<"*"<<p<<endl;   // 把size打印出来
    }else{
        cout<<"未输入参数!!!!!!,默认规模是 "<<m<<"*"<<n<<"*"<<p<<endl;
    }
    double seconds;  //定义double类型的秒数  用于串行记录执行矩阵相乘前后的时间差
    long long *arrayA = new long long[mn];
    long long *arrayB = new long long[np];
    long long *arrayResult = new long long[mp];
    for(int i=0;i<mn;i++){
        arrayA[i] = 1;
    }
    for(int i=0;i<np;i++){
        arrayB[i] = 1;
    }
    for(int i=0;i<mp;i++){
        arrayResult[i] = 0;
    }
    double begin_time = omp_get_wtime();   //记录开始的时间

    #pragma omp  parallel  for
    for(int i=0;i<m;i++){
        for(int j=0;j<n;j++){
            for(int k=0;k<p;k++){
                arrayResult[i*p + k] += arrayA[i*n + j] * arrayB[j*p + k];
            }
        }
    }

//    for(int i=0;i<mp;i++){
//        cout<<arrayResult[i]<<endl;
//    }



    double end_time = omp_get_wtime();  //记录结束的时间
    seconds = end_time - begin_time; //这个CLOCKS_PER_SEC 在不同的操作系统的值不一样 最终算出来的单位是秒
    cout<<"cost time "<<seconds<<" seconds"<<endl; //将最终的消耗时间进行打印
}


/*
单核用时 35.6961
未输入参数!!!!!!,默认规模是 1000*2000*3000
cost time 35.6961 seconds


56个核用时 1.50872
未输入参数!!!!!!,默认规模是 1000*2000*3000
cost time 1.50872 seconds
*/