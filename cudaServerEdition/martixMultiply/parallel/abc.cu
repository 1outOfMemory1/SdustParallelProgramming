#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <iostream>
int arrayScale = 2000;
int arrayScale_square = arrayScale * arrayScale;
#define size 10
using namespace std;


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

    if(argc > 1){ 
	int hhh = atoi(argv[1]); //读取执行时参数 并把它转换为int值 这个值代表矩阵大小 size * size 大小的两个矩阵相乘
        arrayScale = hhh;
        arrayScale_square = arrayScale * arrayScale;
        cout<<"已输入参数， 矩阵规模为"<<arrayScale<<" * "<<arrayScale<<endl;
    }else{
        cout<<"未输入参数！！！ 默认矩阵规模为"<<arrayScale<<" * "<<arrayScale<<endl;
    }
    int *intArrayA = new int[arrayScale_square];
    int *intArrayB = new int[arrayScale_square];
    int *intArrayResult = new int[arrayScale_square];

    int *gpuMappingIntArrayA,*gpuMappingIntArrayB,*gpuMappingIntArrayResult;

    dim3 blocksPerGrid(arrayScale/size,arrayScale/size);
    dim3 threadsPerBock(size,size);

    cudaEvent_t start,stop;
    float elapsedTime = 0;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    //设备端内存分配

    cudaMalloc((void**)&gpuMappingIntArrayA,arrayScale_square * sizeof(int));
    cudaMalloc((void**)&gpuMappingIntArrayB,arrayScale_square * sizeof(int));
    cudaMalloc((void**)&gpuMappingIntArrayResult,arrayScale_square * sizeof(int));


    //初始化
    for(int i = 0;i < arrayScale;i++)
    {
        for(int j = 0;j < arrayScale;j++)
        {
            intArrayA[i*arrayScale + j] = 1;
            intArrayB[i*arrayScale + j] = 1;
        }
    }

    //数据拷贝，主机到设备
    cudaMemcpy(gpuMappingIntArrayA,intArrayA,arrayScale_square * sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(gpuMappingIntArrayB,intArrayB,arrayScale_square * sizeof(int),cudaMemcpyHostToDevice);

    cudaEventRecord(start,0);
    MatMul<<<blocksPerGrid,threadsPerBock>>>(gpuMappingIntArrayA,gpuMappingIntArrayB,gpuMappingIntArrayResult,arrayScale);//调用核函数
    cudaThreadSynchronize();
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedTime,start,stop);
    cudaMemcpy(intArrayResult,gpuMappingIntArrayResult,arrayScale_square * sizeof(int),cudaMemcpyDeviceToHost);



    printf("cost time : %f ms $$$$ %f s \n ",elapsedTime,elapsedTime/1000);
//    for(int i=0;i<arrayScale;i++){
//        for(int j=0;j<arrayScale;j++){
//            printf("%d ",intArrayResult[i*arrayScale + j]);
//        }
//    }


    //释放设备内存
    cudaFree(gpuMappingIntArrayA);
    cudaFree(gpuMappingIntArrayB);
    cudaFree(gpuMappingIntArrayResult);
    free(intArrayA);
    free(intArrayB);
    free(intArrayResult);
    return 0;
}

