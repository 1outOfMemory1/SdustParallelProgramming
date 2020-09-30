#include "SerialMatrixMultiply.h"
#include <malloc.h>
#include <iostream>
using  namespace std;
/**
 * @Author: yhn
 * @Date: 2020/9/16 15:03
 * @Description: ��.cpp�ļ����ڴ���ִ�о�����˵�����
 **/
void  SerialMatrixMultiply::myMalloc(long  ** & longArrayX){
    //����ռ�   size * size ���ռ�
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
    //��һ����ʼ������ ��̬����洢�ռ�  ����A �� B �����ʼ������ ����
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









