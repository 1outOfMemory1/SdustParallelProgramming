#include<iostream>
using namespace std;
const int n = 7;
//共有x个块，对应矩阵的x行
//每块内有y个线程，对应矩阵的y列
__global__ void kernel(int * d_a,int * d_b,int * d_result)
{
    //两维的d_result[][]矩阵存放结果，blockIdx.x代表线程所处理的行坐标，
    //threadIdx.x代表线程所处理的列坐标
    d_result[blockIdx.x*n+threadIdx.x]=0;
    for(int i=0;i<n;i++)
        d_result[blockIdx.x*n+threadIdx.x]+=d_a[blockIdx.x*n+i]*d_b[i*n+threadIdx.x];
}
int main()
{
    //指向CPU端内存的指针

    int  h_a[n*n],h_b[n*n],h_result[n*n];

    //为两个矩阵赋初值
    for(int i=0;i<n;i++)
        for(int j=0;j<n;j++)
            h_a[i*n+j] = h_b[i*n+j] = (10);

    //指向GPU端内存的指针
    int * d_a , *d_b , *d_result ;

    //为GPU中的数据分配内存
    cudaMalloc( (void**)&d_a,sizeof(int)*n*n  );
    cudaMalloc( (void**)&d_b,sizeof(int)*n*n  );
    cudaMalloc( (void**)&d_result,sizeof(int)*n*n  );

    //拷贝CPU中的数据到GPU
    cudaMemcpy(d_a,h_a,sizeof(int)*n*n,cudaMemcpyHostToDevice);
    cudaMemcpy(d_b,h_b,sizeof(int)*n*n,cudaMemcpyHostToDevice);

    //调用内核函数，启动n个block，每个block里有n个线程
    kernel<<<n,n>>>(d_a,d_b,d_result);

    //把GPU中算出来的数据拷回CPU
    cudaMemcpy(h_result,d_result,sizeof(int)*n*n,cudaMemcpyDeviceToHost);

    //显示
    for(int i=0;i<n;i++)
        for(int j=0;j<n;j++)
        {
            cout<<h_result[i*n+j] <<"  ";
            if(j==n-1)
                cout<<'\n';
//            else
//                cout<<'\t'<<'\t';
        }

}
