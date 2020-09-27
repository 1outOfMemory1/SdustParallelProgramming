#include <iostream>
using namespace std;


/*这个函数跟上两个不一样
这个是用来计算一行的累加值 然后进行开方
 * */

//__global__ void sub(double *aa,double *bb,double *result){
//    int row = blockDim.x * blockIdx.x + threadIdx.x;
//    int col = blockDim.y * blockIdx.y + threadIdx.y;
//    result[row *10 +col] = aa[row *10 +col] - bb[col];
//}

//__global__ void sum(double *aa,double *distance){
//    int y =  threadIdx.y;
//    double value = 0;
//    for(int i=0;i<10;i++){
//        value += aa[y * 10 + i];
//    }
//    distance[y] = sqrt(value);
//}

__global__ void sum(double *aa,double *distance){
    int x = blockIdx.x *blockDim.x + threadIdx.x;
    double value = 0;
    for(int i=0;i<10;i++){  //累加一整行的数据
        value += aa[x * 10 + i];
    }
    distance[x] = sqrt(value); //将sum进行开方
}

int main() {
    double *aa = new double[600];
    double *distance = new double[60];

    for(int i=0;i<600;i++){
        aa[i] = 1;
    }

    for(int j=20;j<30;j++){
        aa[j] = 2;
    }//验证成功
    double *cudaAA;
    double *cudaDistance;
    cudaMalloc((void**)&cudaAA,sizeof(double) *600);
    cudaMalloc((void**)&cudaDistance,sizeof(double) * 60);

    cudaMemcpy(cudaAA,aa,sizeof(double) * 600,cudaMemcpyHostToDevice);

    sum<<<dim3(3),dim3(20)>>>(cudaAA,cudaDistance);
    cudaMemcpy(distance,cudaDistance,sizeof(double) * 60,cudaMemcpyDeviceToHost);
    for(int i=0;i<60;i++){
        cout<<distance[i]<<endl;
    }
}
