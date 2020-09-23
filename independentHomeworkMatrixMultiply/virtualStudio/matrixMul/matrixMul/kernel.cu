#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <iostream>
int arrayScale = 2; //���þ����ģ ȫ�ֱ���  
int arrayScale_square = arrayScale * arrayScale;  //��������ģ��ƽ�� ֮��ĳ�����õ�
#define size 1  //���ֵ�Ǹ���һ�������ж��ٸ��̵߳�  �����õ��Ƕ�ά��thread�Ų� 10 *10 Ϊ100 < 1024 ��Ϊ��ʦ�������ݶ���10�ı��� ��������10�ܺ���
using namespace std;


__global__ void MatMul(int* M, int* N, int* P, int scale)  //�����ĺ��ĺ��� �����Դ��е�A B���� result���� �� �����ģ
{
    //��ʵ���г�����Ƶ�Ŀ�ľ���ͬʱ���� �����������ģ��10 * 10  ��ô��Ҫ�õ�100���̼߳���result�����ÿһ��ֵ
    //���Բ��г���ĺ����Ƕ�λ����100���߳� (��ά��ά����ά����һά) Ȼ��Ѽ�������Ϣ���뵽�Դ��� 
    int Col = blockIdx.x * blockDim.x + threadIdx.x; // cloumn �����ǽ�4ά ��ά�� 2ά  ȥ��block�ı߿�������� ��һ���Ƕ�λ����һ��
    int Row = blockIdx.y * blockDim.y + threadIdx.y; // row   ��һ���Ƕ�λ����һ���� 
    float elem1 = 0.0, elem2 = 0.0, value = 0.0;
    for (int i = 0; i < scale; i++)
    {
        elem1 = M[Row * scale + i];//ȡM�����һ�� 
        elem2 = N[i * scale + Col];//ȡN�����һ��
        value += elem1 * elem2;//���
    }
    P[ Row * scale + Col] = value;
}


int main(int argc,char * argv[])
{

    if(argc > 1){
        int hhh = atoi(argv[1]); //��ȡִ��ʱ���� ������ת��Ϊintֵ ���ֵ��������С size * size ��С�������������
        arrayScale = hhh;
        arrayScale_square = arrayScale * arrayScale;
        cout<<"����������� �����ģΪ"<<arrayScale<<" * "<<arrayScale<<endl;
    }else{
        cout<<"δ������������� Ĭ�Ͼ����ģΪ"<<arrayScale<<" * "<<arrayScale<<endl;
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

    //�豸���ڴ����

    cudaMalloc((void**)&gpuMappingIntArrayA,arrayScale_square * sizeof(int));
    cudaMalloc((void**)&gpuMappingIntArrayB,arrayScale_square * sizeof(int));
    cudaMalloc((void**)&gpuMappingIntArrayResult,arrayScale_square * sizeof(int));


    //��ʼ��
    for(int i = 0;i < arrayScale;i++)
    {
        for(int j = 0;j < arrayScale;j++)
        {
            intArrayA[i*arrayScale + j] = 1;
            intArrayB[i*arrayScale + j] = 2;
        }
    }
    intarraya[2] = 10;
    intarraya[3] = 3;
    intarrayb[3] = 1;


    //���ݿ������������豸
    cudaMemcpy(gpuMappingIntArrayA,intArrayA,arrayScale_square * sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(gpuMappingIntArrayB,intArrayB,arrayScale_square * sizeof(int),cudaMemcpyHostToDevice);

    cudaEventRecord(start,0);
    MatMul<<<blocksPerGrid,threadsPerBock>>>(gpuMappingIntArrayA,gpuMappingIntArrayB,gpuMappingIntArrayResult,arrayScale);//���ú˺���
    cudaThreadSynchronize();
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedTime,start,stop);
    cudaMemcpy(intArrayResult,gpuMappingIntArrayResult,arrayScale_square * sizeof(int),cudaMemcpyDeviceToHost);



    printf("cost time : %f ms $$$$ %f s \n",elapsedTime,elapsedTime/1000);
   for(int i=0;i<arrayScale;i++){
       for(int j=0;j<arrayScale;j++){
            printf("%d ",intArrayResult[i*arrayScale + j]);
        }
       printf("\n");
    }


    //�ͷ��豸�ڴ�
    cudaFree(gpuMappingIntArrayA);
    cudaFree(gpuMappingIntArrayB);
    cudaFree(gpuMappingIntArrayResult);
    free(intArrayA);
    free(intArrayB);
    free(intArrayResult);
    return 0;
}
