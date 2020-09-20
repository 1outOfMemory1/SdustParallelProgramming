#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <iostream>
#define ND 2000
#define size 25
using namespace std;


int a[ND][ND];
int b[ND][ND];
int c[ND][ND];


__global__ void MatMul(int *M,int *N,int *P,int width)
{

    int Col = blockIdx.x*blockDim.x + threadIdx.x; // cloumn
    int Row = blockIdx.y*blockDim.y + threadIdx.y; // row

    float elem1 = 0.0,elem2 = 0.0,value = 0.0;
    for(int i = 0;i < width;i++)
    {
        elem1 = M[Col * width + i];//取M矩阵的一行
        elem2 = N[i * width + Row];//取N矩阵的一列
        value += elem1 * elem2;//求和
    }

    P[Col * width + Row] = value;
}


int main()
{

//    int **a=new int*[ND],**b=new int*[ND],**c=new int*[ND];
//    for(int i=0;i<ND;i++){
//        a[i] = new int[ND];
//        b[i] = new int[ND];
//        c[i] = new int[ND];
//    }

    //初始化
    int mm;
    for(int mm = 0;mm < ND;mm++)
    {
        for(int j = 0;j < ND;j++)
        {
            a[mm][j] = 1;
            b[mm][j] = 2;
            c[mm][j] = 0;
        }
    }
//
//    for(int i=0;i<ND;i++){
//        for(int j=0;j<ND;j++){
//            printf("%d ",a[i][j]);
//        }
//    }
//
//    for(int i=0;i<ND;i++){
//        for(int j=0;j<ND;j++){
//            printf("%d ",b[i][j]);
//        }
//    }
//    for(int i=0;i<ND;i++){
//        for(int j=0;j<ND;j++){
//            printf("%d ",c[i][j]);
//        }
//    }




    int *M,*N,*P;

    int width = ND;
    dim3 gridSize(ND/size,ND/size);
    dim3 blockSize(size,size);

    cudaEvent_t start,stop;
    float elapsedTime = 0;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    //设备端内存分配
    cudaMalloc((void**)&M,ND * ND * sizeof(int));
    cudaMalloc((void**)&N,ND * ND * sizeof(int));
    cudaMalloc((void**)&P,ND * ND * sizeof(int));



    int Size = ND * ND;
    //数据拷贝，主机到设备
    cudaMemcpy(M,a,Size * sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(N,b,Size * sizeof(int),cudaMemcpyHostToDevice);

    cudaEventRecord(start,0);
    MatMul<<<gridSize,blockSize>>>(M,N,P,width);//调用核函数
    cudaThreadSynchronize();
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedTime,start,stop);


    cudaError_t error =  cudaMemcpy(c,P,Size * sizeof(int),cudaMemcpyDeviceToHost);

    cout<< error;



    for(int i=0;i<ND;i++){
        for(int j=0;j<ND;j++){
            printf("%d i:%d j:%d ",c[i][j],i,j);
        }
    }


    //释放设备内存
    cudaFree(M);
    cudaFree(N);
    cudaFree(P);

    return 0;
}
