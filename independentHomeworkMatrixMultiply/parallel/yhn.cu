#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <iostream>
const int ND=1000;
#define size 10
using namespace std;


//int a[ND][ND],b[ND][ND],c[ND][ND];


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


int main(int argc,char * argv[])
{
//    int hhh = atoi(argv[1]); //读取执行时参数 并把它转换为int值 这个值代表矩阵大小 size * size 大小的两个矩阵相乘
//    cout<<hhh<<endl;   // 把size打印出来
//    cudaSetDevice(0);

    int (*a)[ND] = new int[ND][ND];
    int (*b)[ND] = new int[ND][ND];
    int (*c)[ND] = new int[ND][ND];

//    int *c = new int[ND*ND];
//    for(int i=0;i<ND;i++){
//        c[i] = new int[ND];
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

    //初始化
    for(int i = 0;i < ND;i++)
    {
        for(int j = 0;j < ND;j++)
        {
            a[i][j] = 1;
            b[i][j] = 1;
        }
    }

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
    cudaMemcpy(c,P,Size * sizeof(int),cudaMemcpyDeviceToHost);



    printf("cost time : %f ms $$$$ %f s \n ",elapsedTime,elapsedTime/1000);
//    for(int i=0;i<ND;i++){
//        for(int j=0;j<ND;j++){
//            printf("%d ",c[i][j]);
//        }
//    }


    //释放设备内存
    cudaFree(M);
    cudaFree(N);
    cudaFree(P);
    free(a);
    free(b);
    free(c);
    return 0;
}
