#include <iostream>
#include <stdio.h>
using namespace std;
int main(){
    //矩阵相乘
    int singleProcessRowNum=3,n=4,p=5;
    int *arrayA =new int[singleProcessRowNum*n];
    int *arrayB = new int[n *p];
    int *arrayResult = new int[singleProcessRowNum * p];
    for(int i=0;i<singleProcessRowNum*n /2;i++){
        arrayA[i]=1;
    }
    for(int i=singleProcessRowNum*n /2;i<singleProcessRowNum*n;i++){
        arrayA[i]=2;
    }


    for(int i=0;i<n*p;i++){
        arrayB[i]=2;
    }

    for(int i=0;i<singleProcessRowNum*p;i++){
        arrayResult[i]=0;
    }




    for (int i = 0; i < singleProcessRowNum; ++i) {
        for (int j = 0; j < n; ++j) {
            for (int k = 0; k < p; ++k) {
                arrayResult[i*p + k] += arrayA[i*n + j] * arrayB[j*p + k];
            }
        }
    }


    for(int i=0;i<singleProcessRowNum;i++){
        for(int j =0;j<p;j++){
            printf("%d ",arrayResult[i * p + j]);
        }
        printf("\n");
    }
}