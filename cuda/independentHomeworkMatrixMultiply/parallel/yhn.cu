#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <iostream>
int arrayScale = 2000; //设置矩阵规模 全局变量
int arrayScale_square = arrayScale * arrayScale;  //算出矩阵规模的平方 之后的程序会用到
#define size 2  //这个值是更改一个块中有多少个线程的  我设置的是二维的thread排布 10 *10 为100 < 1024 因为老师给的数据都是10的倍数 所以设置10很合适
using namespace std;


__global__ void MatMul(int* M, int* N, int* P, int scale)  //真正的核心函数 传入显存中的A B数组 result数组 和 数组规模
{
    //其实并行程序设计的目的就是同时计算 如果你的数组规模是10 * 10  那么需要用到100个线程计算result矩阵的每一个值
    //所以并行程序的核心是定位到这100个线程 (多维降维到二维或者一维) 然后把计算后的信息存入到显存中
    int Col = blockIdx.x * blockDim.x + threadIdx.x; // cloumn 这里是将4维 降维到 2维  去除block的边框就做到了 这一行是定位到那一列
    int Row = blockIdx.y * blockDim.y + threadIdx.y; // row   这一行是定位到哪一个行
    float elem1 = 0.0, elem2 = 0.0, value = 0.0;
    for (int i = 0; i < scale; i++)
    {
        elem1 = M[Row * scale + i];//取M矩阵的一行
        elem2 = N[i * scale + Col];//取N矩阵的一列
        value += elem1 * elem2;//求和
    }
    P[ Row * scale + Col] = value;
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

    int *intArrayA = new int[arrayScale_square];   // A矩阵
    int *intArrayB = new int[arrayScale_square];   // B矩阵
    int *intArrayResult = new int[arrayScale_square];  // 结果矩阵

    int *gpuMappingIntArrayA,*gpuMappingIntArrayB,*gpuMappingIntArrayResult;  //显存映射矩阵

    dim3 blocksPerGrid(arrayScale/size,arrayScale/size);  // grid中block排布方式
    dim3 threadsPerBock(size,size);  // block中thread的排布方式
    cudaEvent_t start,stop;  // 记录cuda的运行时间
    float elapsedTime = 0;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    //cuda中申请矩阵A B和结果矩阵的空间
    cudaMalloc((void**)&gpuMappingIntArrayA,arrayScale_square * sizeof(int));
    cudaMalloc((void**)&gpuMappingIntArrayB,arrayScale_square * sizeof(int));
    cudaMalloc((void**)&gpuMappingIntArrayResult,arrayScale_square * sizeof(int));


    //初始化 A B数组
    for(int i = 0;i < arrayScale;i++)
    {
        for(int j = 0;j < arrayScale;j++)
        {
            intArrayA[i*arrayScale + j] = 1;
            intArrayB[i*arrayScale + j] = 1;
        }
    }
//    intarraya[2] = 10;
//    intarraya[3] = 3;
//    intarrayb[3] = 1;


    //数据拷贝，主机到设备  将内存中的 A B 数组数据拷贝到 显存中的A B数组中去
    cudaMemcpy(gpuMappingIntArrayA,intArrayA,arrayScale_square * sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(gpuMappingIntArrayB,intArrayB,arrayScale_square * sizeof(int),cudaMemcpyHostToDevice);

    cudaEventRecord(start,0);
    // 执行核函数 计算结果数组的每一个值
    MatMul<<<blocksPerGrid,threadsPerBock>>>(gpuMappingIntArrayA,gpuMappingIntArrayB,gpuMappingIntArrayResult,arrayScale);//调用核函数
    cudaThreadSynchronize();
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedTime,start,stop);
    // 将结果数组的每一个值拷贝回内存
    cudaMemcpy(intArrayResult,gpuMappingIntArrayResult,arrayScale_square * sizeof(int),cudaMemcpyDeviceToHost);


    // 输出执行cuda执行时间
    printf("cost time : %f ms $$$$ %f s \n",elapsedTime,elapsedTime/1000);
//    for(int i=0;i<arrayScale;i++){
//        for(int j=0;j<arrayScale;j++){
//            printf("%d ",intArrayResult[i*arrayScale + j]);
//        }
//        printf("\n");
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
