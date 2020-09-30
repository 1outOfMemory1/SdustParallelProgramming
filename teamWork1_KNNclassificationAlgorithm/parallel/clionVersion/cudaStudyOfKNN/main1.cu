#include <iostream>
using namespace std;

/*
这个程序是在main.cu 的基础上将block和thread改为二维排布 然后再进行平方
这样做的目的是计算出中间结果 之后再进行一下累加 然后进行开方就能算出距离了 （main2 函数中进行这个计算）

*/
__global__ void sub(double *aa,double *bb,double *result){
    //四维排布 降维为二维排布  其他还是一样的
    int row = blockDim.x * blockIdx.x + threadIdx.x;
    int col = blockDim.y * blockIdx.y + threadIdx.y;
    result[row *10 +col] =pow(aa[row *10 +col] - bb[col] , 2);
}

int main() {
    double *aa = new double[600];
    double *bb = new double[10];
    double *result = new double[600];
    for(int i=0;i<600;i++){
        aa[i] = 4;
    }
    aa[23] = 13; //用来检验数据是否正确 主要是矩阵是否是转置的 事实证明没有
    cout<<endl;
    for(int j=0;j<10;j++){
        bb[j] = 1;
    }
    double *cudaAA;
    double *cudaBB;
    double *cudaResult;
    cudaMalloc((void**)&cudaAA,sizeof(double) *600);
    cudaMalloc((void**)&cudaBB,sizeof(double) * 10);
    cudaMalloc((void**)&cudaResult,sizeof(double) * 600);

    cudaMemcpy(cudaAA,aa,sizeof(double) * 600,cudaMemcpyHostToDevice);
    cudaMemcpy(cudaBB,bb,sizeof(double) * 10,cudaMemcpyHostToDevice);

    sub<<<dim3(6,1),dim3(10,10)>>>(cudaAA,cudaBB,cudaResult);
    cudaMemcpy(result,cudaResult,sizeof(double) * 600,cudaMemcpyDeviceToHost);
    for(int i=0;i<600;i++){
        if(i%10 == 0 && i!=0)
            cout<<endl;
        cout<<result[i]<<" ";
    }
}
