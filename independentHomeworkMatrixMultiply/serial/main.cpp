#include "SerialMatrixMultiply.h"
#include <time.h>
#include <iostream>

using namespace std;
int main(int argc,char * argv[]){
    int a = atoi(argv[1]); //��ȡִ��ʱ���� ������ת��Ϊintֵ ���ֵ��������С size * size ��С�������������
    cout<<a<<endl;   // ��size��ӡ����
    double seconds;  //����double���͵�����  ���ڴ��м�¼ִ�о������ǰ���ʱ���
    SerialMatrixMultiply *m = new SerialMatrixMultiply(a);  //�½�һ���� ��a Ҳ���Ǿ���Ĺ�ģ���ȥ
    clock_t begin_time = clock();   //��¼��ʼ��ʱ��
    m->multiply();  //ִ�о���ĳ˷�
    clock_t end_time = clock();  //��¼������ʱ��
    seconds = ((double)end_time - begin_time) / CLOCKS_PER_SEC; //���CLOCKS_PER_SEC �ڲ�ͬ�Ĳ���ϵͳ��ֵ��һ�� ����������ĵ�λ����
    cout<<"cost time "<<seconds<<" seconds"<<endl; //�����յ�����ʱ����д�ӡ
}