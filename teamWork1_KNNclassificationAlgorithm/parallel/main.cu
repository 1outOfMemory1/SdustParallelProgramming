#include <vector>
#include <string>
#include <ctime>
#include <cstdlib>
#include "yhncsv.h"
#include "common.h"
#include <map>

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

int myRandom(int i){
    int randomNum = rand() % i;
    return randomNum;
}
__global__ void sumMatrix(double *aa,double *distance,int columnSize){
    int x = blockIdx.x *blockDim.x + threadIdx.x;
    double value = 0;
    for(int i=0;i<columnSize;i++){
        value += aa[x * columnSize + i];
    }
    distance[x] = sqrt(value);
}


//���knn������һ������ �������  һ�в������� ����  ����ѵ���������еľ��� Ȼ����������k��������Ԥ��ֵ
bool knn(vector<double> * testPiece, int position ,vector<vector<double>> *doubleDataArray,vector<string> * resultVector,int k,set<string>* resultSet){
    double maxWeight = -1;  // �����洢���Ȩ��
    string maxWeightStr = "";  // �����洢���Ȩ�ص��ַ���  Ҳ����Ԥ��ֵ
    bool flag = false;   // ���ظ������� �����ж�Ԥ���Ƿ���ȷ
    double sum = 0;

    // 1.�����
    dim3 firstBlocksPerGrid(trainDataSize/threadSize,columnSize/threadSize);
    dim3 firstThreadsPerBlock(threadSize,threadSize);
    //����ռ�
    double * doubleArrayResult = new double[trainDataSize*columnSize];
    double *cudaDoubleArray; //��������
    double *cudaTestArrayPiece; //һ�в��Լ�����
    double *cudaAfterSubAndSquareDoubleArrayResult;
    cudaMalloc((void**)&cudaDoubleArray,sizeof(double) * trainDataSize * columnSize ); //�����Դ�ռ�
    cudaMalloc((void**)&cudaTestArrayPiece,sizeof(double) * columnSize);  //����һά����Ŀռ�
    cudaMalloc((void**)&cudaAfterSubAndSquareDoubleArrayResult,sizeof(double) * trainDataSize * columnSize ); //�����Դ�ռ�
    double *doubleArrayA = new double[trainDataSize * columnSize]; //��ֵ�����ֵ������ vector����
    for(int i=0;i<trainDataSize;i++){
        for(int j =0;j<columnSize;j++){
            doubleArrayA[i* columnSize +j] = doubleDataArray->at(i).at(j);
        }
    }
    cudaMemcpy(cudaDoubleArray,doubleArrayA,sizeof(double)  * columnSize * trainDataSize ,cudaMemcpyHostToDevice); //��ѵ���������ݿ��뵽�Դ���
    double  *doubleArrayB = new double[columnSize];
    for(int i=0;i<columnSize;i++){
        doubleArrayB[i] = testPiece->at(i);
    }
    cudaMemcpy(cudaTestArrayPiece,doubleArrayB ,sizeof(double) * columnSize ,cudaMemcpyHostToDevice); //��test�����ݴ���
    //ִ�к˺���
    MatrixSubAndSquare<<<firstBlocksPerGrid,firstThreadsPerBlock>>>(cudaDoubleArray,cudaTestArrayPiece,cudaAfterSubAndSquareDoubleArrayResult,columnSize);
    //�������������  ��һ�����м䲽��
//    cudaMemcpy(doubleArrayResult,cudaAfterSubAndSquareDoubleArrayResult,trainDataSize * columnSize *sizeof(double)  ,cudaMemcpyDeviceToHost); //��ѵ���������ݿ��뵽�Դ���)
//    //��ӡ���
//    for(int i=0;i<trainDataSize;i++){
//        for(int j=0;j<columnSize;j++){
//            cout<< doubleArrayResult[i*columnSize + j]<<"    ";
//        }
//        cout<<endl;
//    }



    //�ͷ��Դ�  ע��û���ͷ� size�� columnSize * trainDataSize ���Դ� ��Ϊ��߻���Ҫʹ��
    cudaFree(cudaDoubleArray);
    cudaFree(cudaTestArrayPiece);
//    cudaFree(cudaAfterSubAndSquareDoubleArrayResult);  //ע�����ﲻ�����ͷ���Ϊ��������һ������
    //�ͷ��ڴ�
    free(doubleArrayA);
    free(doubleArrayB);

    double *distanceArray = new double[trainDataSize]; //����ռ� ������ž�������
    double *cudaDistanceArray; //����ռ� ������ž�������
    cudaMalloc((void**)&cudaDistanceArray,sizeof(double) * trainDataSize ); //�����ž����Դ�ռ�
    sumMatrix<<<dim3(trainDataSize/threadSize),dim3(threadSize)>>>(cudaAfterSubAndSquareDoubleArrayResult,cudaDistanceArray,columnSize);
    cudaMemcpy(distanceArray,cudaDistanceArray,sizeof(double) *trainDataSize ,cudaMemcpyDeviceToHost);

//    for(int i=0;i<trainDataSize ;i++ ){
//        cout<<distanceArray[i]<<endl;
//    }


    //����þ���֮����Ҫ�����ݺ���ʵֵ��Ӧ����
     auto *realityAndDistanceMap = new map<double,string>;
     for(int i=0;i<trainDataSize;i++){
         realityAndDistanceMap->insert(pair<double,string>(distanceArray[i] ,resultVector->at(i)));
     }


    // 2.������������
    // 3.ȡǰk��


    // 4.ͳ��Ȩ�� �������׼ȷ
    auto *weightMap = new map<string,double>;
    auto  setItr = resultSet->begin();
    for(;setItr!=resultSet->end();setItr++){
        weightMap->insert(pair<string,double>(*setItr,0));
    }
    map<double,string>::iterator iter;
    iter = realityAndDistanceMap->begin();
    for(int i=0;i<k;i++,iter++){ //����sumֵ �������sumֵ
        sum  += iter->first;
    }

    iter = realityAndDistanceMap->begin();
    for(int i=0;i<k;i++ ,iter++){  //ǰk��Ԫ�ص�Ȩ�������
        (*weightMap)[iter->second] += 1 - (iter->first / sum) ; //����Խ�� Ȩ��Խ��
    }



    for(pair<string,double> p :*weightMap ){
        if(p.second > maxWeight){
            maxWeight = p.second;
            maxWeightStr = p.first;
        }
    }

//    if(resultVector->at(position) == realityAndDistanceMap->begin()->second){
//        cout<<"Ԥ����ȷ"<<endl;
//        return true;
//    }
    if(resultVector->at(position).compare(maxWeightStr)  == 0){
//        cout<<"Ԥ����ȷ"<<endl;
        return true;
    }
    else{
//        cout<<"Ԥ�����"<<endl;
        return false;
    }
}


int main() {
    int k=10; //  ��������ȡǰ k ���������������
    //��һ�� ��ʼ�����в���
    vector<vector<double>> *doubleDataArray = nullptr; //��ά���� �����������
    vector<string> * headerNameVector = nullptr;
    vector<string> * resultVector = nullptr;
    set<string> * realitySet = nullptr;
    ifstream inputFile;   //�����ļ�������
    string fileName = "../diabetes.csv";  //�����ļ�����
    inputFile.open(fileName);  //���ļ�
    Csv * csvReader = new Csv(&inputFile);  //���ļ��������ȥ
    realitySet = csvReader->getResultSet();
    headerNameVector =  csvReader->getHeaderNameVector(); //��ȡͷ�������� ���������������
    doubleDataArray = csvReader->getDoubleData(); //�����е������õ�
//    csvReader->printDoubleDataVector(); //��ӡ��������
    resultVector = csvReader->getResultVector();
    columnSize = doubleDataArray->at(0).size();  //�����е�����
    dataSize = doubleDataArray->size();  //��¼���ݼ�������
    trainDataSize = trainDataProportion * dataSize;  //��¼ѵ����������
    testDataSize = dataSize - trainDataSize; //��¼���Լ�������
    //random_shuffle(doubleDataArray->begin(),doubleDataArray->end(),myRandom); // �����ݴ���ע����������� myRandom��һ��������ַ ��random_shuffle���� �������
    //������� ������������ͬ ��ô�ͽ��� ���� ��
    srand((unsigned int)time(NULL));
    for (int i = 0; i < dataSize; ++i) {
        int n1 = (rand() % dataSize);//����n���ڵ������  n������Ԫ�ظ���
        int n2 = (rand() % dataSize);
        if (n1 != n2) { //�������������� ���±�Ϊ�����������������н���
            swap(doubleDataArray->at(n1),doubleDataArray->at(n2));

            swap(resultVector->at(n1),resultVector->at(n2));
        }
    }


    int count = 0;
    for(int i=0;i<testDataSize;i++){
        bool flag =  knn(&doubleDataArray->at(trainDataSize - 1 + i),trainDataSize +i -1 ,doubleDataArray,resultVector,k,realitySet);
        if(flag){
            count++;
        }
    }
    cout<<"׼ȷ��Ϊ"<<(float )count/testDataSize *100 <<"%" ;
//    csvReader->printHeaderVector();  //��ӡͷ�������ַ��� ����������е�����
//    csvReader->printResultVector(); //��ӡ����е�����
//    csvReader->printResultInformation();




}
