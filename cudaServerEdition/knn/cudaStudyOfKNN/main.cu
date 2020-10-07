#include <iostream>
using namespace std;


//这个程序是用来测试 一个block中含有100个一维排布的线程 用于计算 一个二维矩阵(只不过存储是一维形式的) 减去一个相同列数的一维数组
/* 例子
10 * 10 的矩阵 aa
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4


1 * 10 的矩阵 bb
1  1  1  1  1  1  1  1  1


10 * 10 的矩阵 result
3  3  3  3  3  3  3  3  3
3  3  3  3  3  3  3  3  3
3  3  3  3  3  3  3  3  3
3  3  3  3  3  3  3  3  3
3  3  3  3  3  3  3  3  3
3  3  3  3  3  3  3  3  3
3  3  3  3  3  3  3  3  3
3  3  3  3  3  3  3  3  3
3  3  3  3  3  3  3  3  3
 */

__global__ void sub(double *aa,double *bb,double *result){
    int xx = threadIdx.x;
//    int row = xx / 10;  row没有什么用
    int col = xx % 10;  //这里为了方便演示 所以直接模10了 可以将值直接传入其中
    result[xx] = aa[xx] - bb[col]; //这个是核心语句 定位到每个thread的xx参数范围是1-100 只有col是1-10
}

int main() {
    double *aa = new double[100];
    double *bb = new double[10];
    double *result = new double[100];
    for(int i=0;i<100;i++){
//        if(i%10 == 0 && i!=0)
//            cout<<endl;
        aa[i] = 4;
//        cout<<aa[i]<<" ";
    }
//    aa[23] = 13; //用来验证矩阵是否正确
    cout<<endl;
    for(int j=0;j<10;j++){
        bb[j] = 1;
    }
    double *cudaAA;
    double *cudaBB;
    double *cudaResult;
    cudaMalloc((void**)&cudaAA,sizeof(double) *100);
    cudaMalloc((void**)&cudaBB,sizeof(double) * 10);
    cudaMalloc((void**)&cudaResult,sizeof(double) * 100);

    cudaMemcpy(cudaAA,aa,sizeof(double) * 100,cudaMemcpyHostToDevice);
    cudaMemcpy(cudaBB,bb,sizeof(double) * 10,cudaMemcpyHostToDevice);


    sub<<<1,100>>>(cudaAA,cudaBB,cudaResult);
    cudaMemcpy(result,cudaResult,sizeof(double) * 100,cudaMemcpyDeviceToHost);
    for(int i=0;i<100;i++){
        if(i%10 == 0 && i!=0)
            cout<<endl;
        cout<<result[i]<<" ";
    }
}
