#include <iostream>
using namespace std;


//����������������� һ��block�к���100��һά�Ų����߳� ���ڼ��� һ����ά����(ֻ�����洢��һά��ʽ��) ��ȥһ����ͬ������һά����
/* ����
10 * 10 �ľ��� aa
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4
4  4  4  4  4  4  4  4  4


1 * 10 �ľ��� bb
1  1  1  1  1  1  1  1  1


10 * 10 �ľ��� result
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
//    int row = xx / 10;  rowû��ʲô��
    int col = xx % 10;  //����Ϊ�˷�����ʾ ����ֱ��ģ10�� ���Խ�ֱֵ�Ӵ�������
    result[xx] = aa[xx] - bb[col]; //����Ǻ������ ��λ��ÿ��thread��xx������Χ��1-100 ֻ��col��1-10
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
//    aa[23] = 13; //������֤�����Ƿ���ȷ
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
