#include <vector>
#include <string>
#include <ctime>
#include <cstdlib>
#include "yhncsv.h"
#include "common.h"

using namespace std;

// ȫ�ֱ���
double trainDataProportion = (float )2/3;  //���ڹ涨ѵ����ռ�����ݵı���
int dataSize = 0;
int trainDataSize = 0; //���ڼ�¼ѵ�����Ĵ�С
int testDataSize = 0; //���ڼ�¼���Լ��Ĵ�С
int columnSize = 0;  //���ڼ�¼�����е�����
int threadSize = 2; //һ������ �߳�����32 * 32  =1024 ���ֵ



//һ��������������   ���Լ��е�һ�� ����ѵ�����е�ÿһ����������Ȼ��ƽ��
__global__ void MatrixSubAndSquare(double *trainSet,  //�����ά���� ÿһ��������
                                   double *oneRowOftestSet, //��Ҫ���������Լ���ĳһ��
                                   double *afterSubAndSquareResultArray, //�������������ƽ���������м�����
                                   int columnSize
                                   ){
    //�����grid �ֲ�  rowSize/ThreadSize columnSize/ThreadSize   ThreadSize=32 ThreadSize=32
    // rowSize/ThreadSize * ThreadSize = rowSize   columnSize/ThreadSize = columnSize
    int row = blockDim.x * blockIdx.x + threadIdx.x;
    int col = blockDim.y * blockIdx.y + threadIdx.y;
    double value = trainSet[row * columnSize + col]  - oneRowOftestSet[col]; //��ƽ�����ֵ������������
    afterSubAndSquareResultArray[row * columnSize + col] = value * value;
}

__global__ void knn(){

}


//��Ϊvector�������洢���ݵ� ����ֱ�ӽ����ڴ濽������
//memcpy(doubleArray,&doubleVector[0],doubleVectorSize * sizeof(double));


int myRandom(int i){
    int randomNum = rand() % i;
    return randomNum;
}
//double distance(vector<double>* d1,vector<double> * d2){
//    double dis = 0;
//    int size = d1->size();
//    for (int i = 0;i < size;i++){
//        dis += pow((d1->at(i) - d2->at(i)),2);
//    }
//    return pow(dis,0.5);
//}


//���knn������һ������ �������  һ�в������� ����  ����ѵ���������еľ��� Ȼ����������k��������Ԥ��ֵ
bool knn(vector<double> * testPiece, vector<vector<double>> *doubleDataArray){
    double maxWeight = -1;  // �����洢���Ȩ��
    string maxWeightStr = "";  // �����洢���Ȩ�ص��ַ���  Ҳ����Ԥ��ֵ
    bool flag = false;   // ���ظ������� �����ж�Ԥ���Ƿ���ȷ
    double sum = 0;
    auto *distanceVector = new vector<double>;

    // 1.�����
    dim3 firstBlocksPerGrid(trainDataSize/threadSize,columnSize/threadSize);
    dim3 firstThreadsPerBlock(threadSize,threadSize);
    //����ռ�
    double * result1 = new double[trainDataSize*columnSize];

    double *cudaDoubleArray; //��������
    double * cudaTestArrayPiece; //һ�в��Լ�����
    double *cudaAfterSubAndSquareDoubleArrayResult;

    cudaMalloc((void**)&cudaDoubleArray,sizeof(double) * trainDataSize * columnSize ); //�����Դ�ռ�
    cudaMalloc((void**)&cudaTestArrayPiece,sizeof(double) * columnSize);  //����һά����Ŀռ�
    cudaMalloc((void**)&cudaAfterSubAndSquareDoubleArrayResult,sizeof(double) * trainDataSize * columnSize ); //�����Դ�ռ�

    double *xxx = new double[trainDataSize * columnSize];


    for(int i=0;i<trainDataSize;i++){
        for(int j =0;j<columnSize;j++){
            xxx[i* columnSize +j] = doubleDataArray->at(i).at(j);
//            cout<<xxx[i* columnSize +j]<<"  ";
        }
//        cout<<endl;
    }



//    for(int i=0;i<trainDataSize;i++){
//        cudaMemcpy(&cudaDoubleArray[i],&doubleDataArray->at(i),
//                   sizeof(double)  * columnSize ,
//                   cudaMemcpyHostToDevice); //��ѵ���������ݿ��뵽�Դ���
//    }

    cudaMemcpy(cudaDoubleArray,xxx,
                   sizeof(double)  * columnSize * trainDataSize ,
                   cudaMemcpyHostToDevice); //��ѵ���������ݿ��뵽�Դ���
    double  *yyy = new double[columnSize];
    for(int i=0;i<columnSize;i++){
        yyy[i] = testPiece->at(i);
//        cout<<yyy[i]<<"  ";
    }
    cudaMemcpy(cudaTestArrayPiece,yyy,sizeof(double) * columnSize ,cudaMemcpyHostToDevice); //��test�����ݴ���


/*
 double *trainSet,  //�����ά���� ÿһ��������
 double *oneRowOftestSet, //��Ҫ���������Լ���ĳһ��
 double *afterSubAndSquareResultArray //�������������ƽ���������м�����
 * */


    //ִ�к˺���
    MatrixSubAndSquare<<<firstBlocksPerGrid,firstThreadsPerBlock>>>(cudaDoubleArray,cudaTestArrayPiece,cudaAfterSubAndSquareDoubleArrayResult,columnSize);
//    MatrixSubAndSquare<<<1,dim3(1,1000)>>>(cudaDoubleArray,cudaTestArrayPiece,cudaAfterSubAndSquareDoubleArrayResult,columnSize);

    //�������������
    cudaMemcpy(result1,cudaAfterSubAndSquareDoubleArrayResult,
                      trainDataSize * columnSize *sizeof(double)  ,
                      cudaMemcpyDeviceToHost); //��ѵ���������ݿ��뵽�Դ���)


//    for(int i=0;i<trainDataSize;i++){
//        for(int j=0;j<columnSize;j++){
//            cout<< result1[i*columnSize + j]<<"    ";
//        }
//        cout<<endl;
//    }
//
    for(int i=0;i<trainDataSize;i++){
        yyy[i] = 0;
        for(int j=0;j<columnSize;j++){
            yyy[i] += result1[i*columnSize + j];
        }
        yyy[i] = sqrt(yyy[i]);
    }


    sort(yyy,yyy+trainDataSize);
    for(int i =0; i< trainDataSize;i++){
        cout<<yyy[i]<<endl;
    }
    int bbbb = 0;



    // 2.������������
    // 3.ȡǰk��
    // 4.��Ȩƽ��


    return false;
}


int main() {
    srand(time(0));   //��������� ����ʱ�����������
    int k=10; //  ��������ȡǰ k ���������������
    //��һ�� ��ʼ�����в���
    vector<vector<double>> *doubleDataArray = nullptr; //��ά���� �����������
    vector<string> * headerNameVector = nullptr;
    ifstream inputFile;   //�����ļ�������
    string fileName = "../KNN_Data.csv";  //�����ļ�����
    inputFile.open(fileName);  //���ļ�
    Csv * csvReader = new Csv(&inputFile);  //���ļ��������ȥ
    headerNameVector =  csvReader->getHeaderNameVector(); //��ȡͷ�������� ���������������
    doubleDataArray = csvReader->getDoubleData(); //�����е������õ�
    columnSize = doubleDataArray->at(0).size();  //�����е�����
    dataSize = doubleDataArray->size();  //��¼���ݼ�������
    trainDataSize = trainDataProportion * dataSize;  //��¼ѵ����������
    testDataSize = (1-trainDataProportion) * dataSize; //��¼���Լ�������
    random_shuffle(doubleDataArray->begin(),doubleDataArray->end(),myRandom); // �����ݴ���ע����������� myRandom��һ��������ַ ��random_shuffle���� �������
    knn(&doubleDataArray->at(trainDataSize),doubleDataArray);


    //    csvReader->printDoubleDataVector(); //��ӡ��������
//    csvReader->printHeaderVector();  //��ӡͷ�������ַ��� ����������е�����
//    csvReader->printResultVector(); //��ӡ����е�����
//    csvReader->printResultInformation();




}
