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
int k=14; //  ��������ȡǰ k ���������������
double allKernelFunctionCostTime = 0;
double allCostTime = 0;
string fileName = "F://fashion-mnist_train.csv";  //�����ļ�����



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

__global__ void sumMatrix(double *aa,double *distance,int columnSize){ //����ÿ�еĺ� Ȼ�󿪷�
    int x = blockIdx.x *blockDim.x + threadIdx.x;
    double value = 0;
    for(int i=0;i<columnSize;i++){
        value += aa[x * columnSize + i];
    }
    distance[x] = sqrt(value);
}


//���knn������һ������ �������  һ�в������� ����  ����ѵ���������еľ��� Ȼ����������k��������Ԥ��ֵ
bool knn(vector<double> * testPiece, int position ,vector<vector<double>> *doubleDataVector,vector<string> * resultVector,set<string>* resultSet){
    //1. ��ʼ��һЩ����
    //1.1 ���������ĳ�ʼ��
    double maxWeight = -1;  // �����洢���Ȩ��
    string maxWeightStr = "";  // �����洢���Ȩ�ص��ַ���  Ҳ����Ԥ��ֵ
    bool flag = false;   // ���ظ������� �����ж�Ԥ���Ƿ���ȷ
    double sum = 0;  //�����������֮�����Ȩֵ��ʱ���� ˭������ ȨֵԽ��
    auto *doubleArrayA = new double[trainDataSize * columnSize]; // �����ڴ������ݵ�ʱ����������ʱ�洢ѵ�������� vector�в�ͨ ��ֵ�����ֵ������ vector����
    auto *doubleArrayB = new double[columnSize]; //�������洢���Լ���һ�����ݵ� ���Ϸ�һ��
    //    double * doubleArrayResult = new double[trainDataSize*columnSize];  //���ڴ洢�м����� �������ƽ��������� ����ʱ�������
    //1.2 ӳ��ָ��Ĵ��� ����ָ�� ����ӳ���Դ��е�����
    double *cudaDoubleArray; //�������ݶ�ά���� �Դ��е�����
    double *cudaTestArrayPiece; //һ�в��Լ����� �Դ��е�����
    double *cudaAfterSubAndSquareDoubleArrayResult; //�м�����  �Դ��е�����
    //1.3 �˺�����ģ�Ķ��� ��һ���Ǿ������ �� ƽ���ĺ˺���
    dim3 firstBlocksPerGrid(trainDataSize/threadSize,columnSize/threadSize);
    dim3 firstThreadsPerBlock(threadSize,threadSize);
    dim3 secondBlocksPerGrid(trainDataSize/threadSize);
    dim3 secondThreadsPerBlock(threadSize);
    //2. ����ռ�
    cudaMalloc((void**)&cudaDoubleArray,sizeof(double) * trainDataSize * columnSize ); //�����Դ��ж�ά����Ŀռ� ���ڴ��ѵ��������
    cudaMalloc((void**)&cudaTestArrayPiece,sizeof(double) * columnSize);  //�����������һά����Ŀռ� ��άѵ������ÿһ�ж���ȥһά���Լ��Ķ�Ӧλ������ Ȼ��ƽ��
    cudaMalloc((void**)&cudaAfterSubAndSquareDoubleArrayResult,sizeof(double) * trainDataSize * columnSize ); //�����м������Դ�ռ� ��ģ��ѵ����һ��
    //3.�������ݽ����Դ�
    //3.1����ѵ�����Դ�
    //Ŀǰ��û��ʲô�ð취 ֻ�ܰ������и�ֵ Ӧ��Ҳ���� ���ǿ϶�����Щֱ�ӽ����ڴ����鿽������
    //3.1.1 �Ȱ�����Ū��һ��double������ȥ
    for(int i=0;i<trainDataSize;i++){
        for(int j =0;j<columnSize;j++){
            doubleArrayA[i* columnSize +j] = doubleDataVector->at(i).at(j);
        }
    }
    //3.1.2 ִ��cuda�Դ濽������
    cudaMemcpy(cudaDoubleArray,doubleArrayA,sizeof(double)  * columnSize * trainDataSize ,cudaMemcpyHostToDevice); //��ѵ���������ݿ��뵽�Դ���
    //3.2 �������Լ����� ֻ��һ�� ���Կ�����copy����
    //3.2.1 ��vector<double> ת��Ϊ double ����
    copy(testPiece->begin(),testPiece->end(),doubleArrayB);  //�ֱ��ʾ Ҫ���Ƶ�vector��ͷ, Ҫ���Ƶ�vector��β , Ŀ������
    //3.2.2 ִ��cuda�Դ濽������
    cudaMemcpy(cudaTestArrayPiece,doubleArrayB ,sizeof(double) * columnSize ,cudaMemcpyHostToDevice); //��test�����ݴ���
    //4. ִ�е�һ���˺���
    cudaEvent_t start1,stop1;
    float elapsedTime1 = 0;
    cudaEventCreate(&start1);
    cudaEventCreate(&stop1);
    cudaEventRecord(start1,0);
    MatrixSubAndSquare<<<firstBlocksPerGrid,firstThreadsPerBlock>>>(cudaDoubleArray,cudaTestArrayPiece,cudaAfterSubAndSquareDoubleArrayResult,columnSize);
    cudaEventRecord(stop1,0);
    cudaEventSynchronize(stop1);
    cudaEventElapsedTime(&elapsedTime1,start1,stop1);
//    cout<<"first kennel function cost time:"<<elapsedTime1<<endl;

    //�������������  ��һ�����м䲽�� ���Ե�ʱ���Ŵ���
//    cudaMemcpy(doubleArrayResult,cudaAfterSubAndSquareDoubleArrayResult,trainDataSize * columnSize *sizeof(double)  ,cudaMemcpyDeviceToHost); //��ѵ���������ݿ��뵽�Դ���)
//    //��ӡ������м��� �м䲽�� ����ʹ��
//    for(int i=0;i<trainDataSize;i++){
//        for(int j=0;j<columnSize;j++){
//            cout<< doubleArrayResult[i*columnSize + j]<<"    ";
//        }
//        cout<<endl;
//    }
    //5. �ͷ�һ�����Դ���ڴ�  ע��û���ͷ� cudaAfterSubAndSquareDoubleArrayResult ��Ϊ�м�������Ҫʹ��
    //5.1 �ͷ��Դ�
    cudaFree(cudaDoubleArray); //�ͷ� ��ά����(�Ų�Ϊһά) ѵ��������
    cudaFree(cudaTestArrayPiece); //�ͷ� һά���� ���Լ���һ������
    //5.2 �ͷ��ڴ�
    free(doubleArrayA);
    free(doubleArrayB);
    //6 Ϊִ�еڶ����˺���׼���ռ�(�ڴ���Դ�)
    auto *distanceArray = new double[trainDataSize]; //�����ڴ�ռ� ������ž�������
    double *cudaDistanceArray; //����ռ� ӳ���Դ�ռ� ������ž�������
    cudaMalloc((void**)&cudaDistanceArray,sizeof(double) * trainDataSize ); //�����ž����Դ�ռ�
    //7 ִ�еڶ����˺���
    cudaEvent_t start2,stop2;
    float elapsedTime2 = 0;
    cudaEventCreate(&start2);
    cudaEventCreate(&stop2);
    cudaEventRecord(start2,0);
    sumMatrix<<<secondBlocksPerGrid,secondThreadsPerBlock>>>(cudaAfterSubAndSquareDoubleArrayResult,cudaDistanceArray,columnSize);
    cudaEventRecord(stop2,0);
    cudaEventSynchronize(stop2);
    cudaEventElapsedTime(&elapsedTime2,start2,stop2);
//    cout<<"second kennel function cost time:"<<elapsedTime2<<endl;

//    cout<<"two kennel function cost time:"<<elapsedTime1+elapsedTime2<<endl;
    allKernelFunctionCostTime += elapsedTime1+elapsedTime2;
    //8 �����ľ������鿽�����ڴ� �Ա���ʹ��
    cudaMemcpy(distanceArray,cudaDistanceArray,sizeof(double) *trainDataSize ,cudaMemcpyDeviceToHost);
    //9 �ͷŵ������Դ� ��Ϊ�Ժ��ò�����
    cudaFree(cudaAfterSubAndSquareDoubleArrayResult);  //�ͷŵ��м���������
    cudaFree(cudaDistanceArray);  //�ͷŵ���������
//    for(int i=0;i<trainDataSize ;i++ ){  //��ӡ��������
//        cout<<distanceArray[i]<<endl;
//    }
    //10 �������ݴ���
    //10.1 ��ʼ��һЩstl �Ժ���õ�
    auto *realityAndDistanceMap = new multimap<double,string>;  //������Ϊkey ��ʵֵΪvalue �������ĺô����Զ����� ��Ҫ����multimap ��Ȼ����һ�㲻��һ�� ���Ǿ�������
    auto *weightMap = new map<string,double>;  //Ȩ��map   ���double���ݿ�����Ϊ���� key�������ظ� ���Է����� map
    set<string>::iterator setItr ;  //�����������н��(resultSet) ���set�����˽���������п��� �����ж��Ƿ�ò������ݼ� ֻ�еò����߲��ò����� �Ѿ����ź����
    map<double,string>::iterator mapIter; //���ڱ���
    //10.2 ����þ���֮����Ҫ�����ݺ���ʵֵ��Ӧ����  ֮������ͳ��Ȩֵ��ʱ����õ� realityAndDistanceMap multimap<double,string>
    for(int i=0;i<trainDataSize;i++){
        realityAndDistanceMap->insert(pair<double,string>(distanceArray[i] ,resultVector->at(i)));
    }
    free(distanceArray); //˳�ְ�distanceArray�ͷŵ� �Ժ󲻻�������
    //10.3.��ʼ��Ȩ��map ��value�����0  ͳ��Ȩ�ص�Ŀ�����ۺϿ���k������ĵ��Ӱ�� Լ�ӽ��ĵ�Ȩ��Խ��
    setItr = resultSet->begin();  //resultSet set<string> �ĵ�����
    for(;setItr!=resultSet->end();setItr++){
        weightMap->insert(pair<string,double>(*setItr,0));
    }
    //10.4 ����ǰk������ĵ���ܾ���sum ������Ȩ��
    mapIter = realityAndDistanceMap->begin();
    for(int i=0;i<k;i++,mapIter++){ //����sumֵ �������sumֵ
        sum  += mapIter->first;
    }
    //10.5 �ֱ����ǰk�����Ȩֵ ��������ʵֵ �ӵ����п��ܵ�ֵ�� ����ò�Ȩ��5.4 ���ò�Ȩ��Ϊ 8.4 ���Կ����жϴ�����ǲ��ò�
    mapIter = realityAndDistanceMap->begin();
    for(int i=0;i<k;i++ ,mapIter++){  //ǰk��Ԫ�ص�Ȩ�������
        (*weightMap)[mapIter->second] += 1 - (mapIter->first / sum) ; //����Խ�� Ȩ��Խ��  ע�������� 1- xxx
    }
    //10.6 �ҵ���ߵ��Ǹ�Ȩ�ص�ֵ �����ǲ��ò� Ȼ������ֵ��maxWeightStr
    for(pair<string,double> p :*weightMap ){
        if(p.second > maxWeight){
            maxWeight = p.second;
            maxWeightStr = p.first;
        }
    }
    //10.7 ���ݲ��Լ�����ʵֵ��Ԥ��ֵ�Ա��Ƿ�һ��  ���һ��˵��Ԥ��ɹ�
    if(resultVector->at(position).compare(maxWeightStr)  == 0)
        flag = true;  //flag ��߻�return��ȥ
    else
        flag = false;
    //11 �����ͷŵ����е��ڴ�(�Դ��Ѿ�ȫ���ͷ�)
    free(realityAndDistanceMap); //�ͷ���ʵֵ�;���map
    free(weightMap); //�ͷ�Ȩ��map
    return flag; //����Ԥ��������ʵֵ�Ƿ�ƥ��
}


int main(int argc,char * argv[]) {
    clock_t allTimeBegin = clock();
    if(argc > 1){
        fileName = argv[1];
        cout<<"����������� csv�ļ�Ϊ :   "<<argv[1]<<endl<<endl;
    }else{
        cout<<"δ������������� Ĭ��csv�ļ���:"<<fileName<<endl;
    }

    //1. ��ʼ�����в���
    vector<vector<double>> *doubleDataVector = nullptr; //��ά���� �������ѵ�����Ͳ��Լ�����������
    vector<string> * resultVector = nullptr;  //����� ���ȫ���ַ���
    set<string> * realitySet = nullptr;  //���ظ������н����
    ifstream inputFile;   //�����ļ�������

    //2.����i/o�� ���ļ� Ȼ�����yhnCsv������ȡcsv�ļ�������
    inputFile.open(fileName);  //���ļ�
    Csv * csvReader = new Csv(&inputFile);  //���ļ��������ȥ
    //3. ��ȡ����
    //3.1 ������߼��ϵĻ�ȡ
    realitySet = csvReader->getResultSet();  //��ȡ���ظ������ݼ�
    resultVector = csvReader->getResultVector(); //�õ����еĽ��
    doubleDataVector = csvReader->getDoubleData(); //�����е�ѵ�����Ͳ��Լ��������õ�

    //3.2 ��ȡȫ�ֱ���
    columnSize = doubleDataVector->at(0).size();  //�����е�����
    dataSize = doubleDataVector->size();  //��¼�����ݼ�������
    trainDataSize = trainDataProportion * dataSize;  //��¼ѵ����������  �������� �����ݼ�������
    testDataSize = dataSize - trainDataSize; //��¼���Լ�������
    //4. ͬʱ��ȫ�����ݼ��ͽ�����ݼ�������� ������������ͬ ��ô�ͽ���  ������ͬʱ���ж������Ľ��� swap�����ܺ�ʹ
    srand((unsigned int)time(NULL));  //��ʱ��Ϊ��׼�������
    for (int i = 0; i < dataSize; ++i) {  //��ཻ�� �����ݼ���С ��ʵһ����� ��������ν��
        int n1 = (rand() % dataSize);//����n���ڵ������  n������Ԫ�ظ���
        int n2 = (rand() % dataSize);
        if (n1 != n2) { //�������������� ���±�Ϊ�����������������н���
            swap(doubleDataVector->at(n1),doubleDataVector->at(n2));
            swap(resultVector->at(n1),resultVector->at(n2));
        }
    }
    csvReader->printHeaderVector();  //��ӡͷ�������ַ��� ����������е�����
    csvReader->printResultInformation(); //��ӡresult��Ϣ
    cout<<"kֵΪ��"<<k<<",�����ݼ���"<<dataSize<<"����"<<"ѵ������"<<trainDataSize<<"��,"<<"���Լ���"<<testDataSize<<"��"<<endl;
    int count = 0; //����ͳ�Ƴɹ�Ԥ�������
    for(int i=0;i<testDataSize;i++){
        bool flag =  knn(&doubleDataVector->at(trainDataSize + i), //���Լ���һ��
                         trainDataSize +i  , //���Լ���λ��
                         doubleDataVector, // ���е�����
                         resultVector, //��������ݼ�
                         realitySet); //��������п���ֵ �� set(���ظ�)
//        bool flag =  knn(&doubleDataVector->at(69), //���Լ���һ��
//                         69 , //���Լ���λ��
//                         doubleDataVector, // ���е�����
//                         resultVector, //��������ݼ�
//                         realitySet); //��������п���ֵ �� set(���ظ�)
        if(flag){
            count++;
        }
    }
    clock_t allTimeEnd = clock();

    cout<<"�˴���������ݼ���׼ȷ��Ϊ: "<<(float )count/testDataSize *100 <<"%"<<endl ;
    cout<<"all Kernel Function Cost Time: "<<allKernelFunctionCostTime<<" ms"<<endl;
    cout<<"total Cost Time:"<<(allTimeEnd - allTimeBegin)/CLOCKS_PER_SEC <<" s"<<endl;
    free(csvReader);
}
