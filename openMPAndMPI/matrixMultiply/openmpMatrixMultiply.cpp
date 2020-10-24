#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cstdio>
#include <stdlib.h>
#include <omp.h>

using namespace std;

// ������� �϶��� m * n  ����  n * p
long long  m=2000,n=2000,p=2000;
long long mn = m * n;
long long np = n * p;
long long mp = m * p;
int main(int argc,char * argv[]) {
    if(argc >1){
        int a = atoi(argv[1]); //��ȡִ��ʱ���� ������ת��Ϊintֵ ���ֵ��������С size * size ��С�������������
        cout<<"��������� �����ģΪ "<<m<<"*"<<n<<"*"<<p<<endl;   // ��size��ӡ����
    }else{
        cout<<"δ�������!!!!!!,Ĭ�Ϲ�ģ�� "<<m<<"*"<<n<<"*"<<p<<endl;
    }
    double seconds;  //����double���͵�����  ���ڴ��м�¼ִ�о������ǰ���ʱ���
    long long *arrayA = new long long[mn];
    long long *arrayB = new long long[np];
    long long *arrayResult = new long long[mp];
    for(int i=0;i<mn;i++){
        arrayA[i] = 1;
    }
    for(int i=0;i<np;i++){
        arrayB[i] = 1;
    }
    for(int i=0;i<mp;i++){
        arrayResult[i] = 0;
    }
    double begin_time = omp_get_wtime();   //��¼��ʼ��ʱ��
    int j;
    int k;
    #pragma omp  parallel  for private(j, k)
    for(int i=0;i<m;i++){
        for(j=0;j<n;j++){
            for(k=0;k<p;k++){
                arrayResult[i*p + k] += arrayA[i*n + j] * arrayB[j*p + k];
            }
        }
    }

//    for(int i=0;i<mp;i++){
//        cout<<arrayResult[i]<<endl;
//    }



    double end_time = omp_get_wtime();  //��¼������ʱ��
    seconds = end_time - begin_time; //���CLOCKS_PER_SEC �ڲ�ͬ�Ĳ���ϵͳ��ֵ��һ�� ����������ĵ�λ����
    cout<<"cost time "<<seconds<<" seconds"<<endl; //�����յ�����ʱ����д�ӡ
}


/*
������ʱ 35.6961
δ�������!!!!!!,Ĭ�Ϲ�ģ�� 1000*2000*3000
cost time 35.6961 seconds

56������ʱ 1.50872
δ�������!!!!!!,Ĭ�Ϲ�ģ�� 1000*2000*3000
cost time 1.50872 seconds
*/