#include<iostream>
using namespace std;
const int n = 1024;
//当n大于1024时，需要对块的维度和网格的维度做一些调整
//每个块内有32*32个线程，网格中共有(n/32)*(n/32)个块
__global__ void kernel(int * d_a,int * d_b,int * d_result)
{
    //两维的d_result[][]矩阵存放结果，blockDim.y*blockIdx.y+threadIdx.y代表线程所处理的行坐标，
    //blockDim.x*blockIdx.x+threadIdx.x代表线程所处理的列坐标
    int r=blockDim.y*blockIdx.y+threadIdx.y;
    int c=blockDim.x*blockIdx.x+threadIdx.x;
    d_result[r*n+c] = 0;
    for(int i=0;i<n;i++)
        d_result[r*n+c]+=d_a[r*n+i]*d_b[i*n+c];
}
int main()
{
    //指向CPU端内存的指针
    int  *h_a = new int[n*n];
    int  *h_b = new int[n*n];
    int  *h_result = new int[n*n];

    //为两个矩阵赋初值
    for(int i=0;i<n*n;i++){
        h_a[i] = 1;
        h_b[i] = 1;
    }



    //指向GPU端内存的指针
    int * d_a , *d_b , *d_result ;

    //为GPU中的数据分配内存
    cudaMalloc( (void**)&d_a,sizeof(int)*n*n  );
    cudaMalloc( (void**)&d_b,sizeof(int)*n*n  );
    cudaMalloc( (void**)&d_result,sizeof(int)*n*n  );

    //拷贝CPU中的数据到GPU
    cudaMemcpy(d_a,h_a,sizeof(int)*n*n,cudaMemcpyHostToDevice);
    cudaMemcpy(d_b,h_b,sizeof(int)*n*n,cudaMemcpyHostToDevice);

    //调用内核函数
    kernel<<<dim3(n/32,n/32),dim3(32,32)>>>(d_a,d_b,d_result);


    //把GPU中算出来的数据拷回CPU
    cudaMemcpy(h_result,d_result,sizeof(int)*n*n,cudaMemcpyDeviceToHost);

    //显示
    for(int i=0;i<n;i++)
        for(int j=0;j<n;j++)
        {
            cout<<h_result[i*n+j]<<"   ";
            if(j==n-1)
                cout<<'\n';
        }

}
