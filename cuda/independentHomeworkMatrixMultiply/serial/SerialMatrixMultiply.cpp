#include "SerialMatrixMultiply.h"
#include <malloc.h>
#include <iostream>
using  namespace std;
/**
 * @Author: yhn
 * @Date: 2020/9/16 15:03
 * @Description: 本.cpp文件用于串行执行矩阵相乘的任务
 **/
void  SerialMatrixMultiply::myMalloc(long  ** & longArrayX){
    //申请空间   size * size 个空间
    longArrayX = new long*[size];
    for(long i= 0;i<size;i++){
        longArrayX[i] = new long[size];
    }
}

void SerialMatrixMultiply::setArray(long ** &longArrayX) {
     myMalloc(longArrayX);
    for(int i=0;i<size;i++){
        for(int j=0;j<size;j++){
            longArrayX[i][j] = i+j;
        }
    }

}

void SerialMatrixMultiply::setZero(long ** & longArrayX) {
    myMalloc(longArrayX);
    for(int i=0;i<size;i++){
        for(int j=0;j<size;j++){
            longArrayX[i][j] = 0;
        }
    }
}



SerialMatrixMultiply::SerialMatrixMultiply(long ssize):size(ssize){
    //第一步初始化数组 动态申请存储空间  其中A 和 B 数组初始化数字 其他
     setArray(longArrayA);
     setArray(longArrayB);
     setZero(longArrayC);
}

void SerialMatrixMultiply::multiply() {
    for(long i=0;i<size;i++){
        for(long j=0;j<size;j++){
            for(long k=0;k<size;k++){
                longArrayC[i][j] += longArrayA[i][k] * longArrayB[k][j];
            }
        }
    }
}



void SerialMatrixMultiply::print(long ** longArrayX) {
    for(long i=0;i<size;i++){
        for(long j=0;j<size;j++){
            cout<<longArrayX[i][j]<<" ";
        }
        cout<<endl;
    }
}

void SerialMatrixMultiply::printCArray() {
    print(longArrayC);
}









