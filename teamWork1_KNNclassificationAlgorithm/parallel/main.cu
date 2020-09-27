#include <vector>
#include <string>
#include <ctime>
#include <cstdlib>
#include "yhncsv.h"
#include "common.h"
#include <map>

using namespace std;

// 全局变量
double trainDataProportion = (float )2/3;  //用于规定训练集占总数据的比例
int dataSize = 0;
int trainDataSize = 0; //用于记录训练集的大小
int testDataSize = 0; //用于记录测试集的大小
int columnSize = 0;  //用于记录数据列的数量
int threadSize = 2; //一个块中 线程数是32 * 32  =1024 最大值



//一次性算整个数组   测试集中的一行 都被训练集中的每一行先做减法然后平方
__global__ void MatrixSubAndSquare(double *trainSet,  //传入二维数组 每一个都可以
                                   double *oneRowOftestSet, //需要计算距离测试集的某一行
                                   double *afterSubAndSquareResultArray, //经过减法计算和平方计算后的中间数据
                                   int columnSize
                                   ){
    //设想的grid 分布  rowSize/ThreadSize columnSize/ThreadSize   ThreadSize=32 ThreadSize=32
    // rowSize/ThreadSize * ThreadSize = rowSize   columnSize/ThreadSize = columnSize
    int row = blockDim.x * blockIdx.x + threadIdx.x;
    int col = blockDim.y * blockIdx.y + threadIdx.y;
    double value = trainSet[row * columnSize + col]  - oneRowOftestSet[col]; //把平方后的值放在新数组中
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


//这个knn函数的一次运行 算出的是  一行测试数据 距离  所有训练集所有行的距离 然后根据最近的k个数据来预测值
bool knn(vector<double> * testPiece, int position ,vector<vector<double>> *doubleDataArray,vector<string> * resultVector,int k,set<string>* resultSet){
    double maxWeight = -1;  // 用来存储最大权重
    string maxWeightStr = "";  // 用来存储最大权重的字符串  也就是预测值
    bool flag = false;   // 返回给主函数 用于判断预测是否正确
    double sum = 0;

    // 1.求距离
    dim3 firstBlocksPerGrid(trainDataSize/threadSize,columnSize/threadSize);
    dim3 firstThreadsPerBlock(threadSize,threadSize);
    //申请空间
    double * doubleArrayResult = new double[trainDataSize*columnSize];
    double *cudaDoubleArray; //整个数据
    double *cudaTestArrayPiece; //一行测试集数据
    double *cudaAfterSubAndSquareDoubleArrayResult;
    cudaMalloc((void**)&cudaDoubleArray,sizeof(double) * trainDataSize * columnSize ); //申请显存空间
    cudaMalloc((void**)&cudaTestArrayPiece,sizeof(double) * columnSize);  //申请一维数组的空间
    cudaMalloc((void**)&cudaAfterSubAndSquareDoubleArrayResult,sizeof(double) * trainDataSize * columnSize ); //申请显存空间
    double *doubleArrayA = new double[trainDataSize * columnSize]; //把值逐个赋值给数组 vector不行
    for(int i=0;i<trainDataSize;i++){
        for(int j =0;j<columnSize;j++){
            doubleArrayA[i* columnSize +j] = doubleDataArray->at(i).at(j);
        }
    }
    cudaMemcpy(cudaDoubleArray,doubleArrayA,sizeof(double)  * columnSize * trainDataSize ,cudaMemcpyHostToDevice); //将训练集的数据拷入到显存中
    double  *doubleArrayB = new double[columnSize];
    for(int i=0;i<columnSize;i++){
        doubleArrayB[i] = testPiece->at(i);
    }
    cudaMemcpy(cudaTestArrayPiece,doubleArrayB ,sizeof(double) * columnSize ,cudaMemcpyHostToDevice); //将test的数据传入
    //执行核函数
    MatrixSubAndSquare<<<firstBlocksPerGrid,firstThreadsPerBlock>>>(cudaDoubleArray,cudaTestArrayPiece,cudaAfterSubAndSquareDoubleArrayResult,columnSize);
    //将结果拷贝回来  这一步是中间步骤
//    cudaMemcpy(doubleArrayResult,cudaAfterSubAndSquareDoubleArrayResult,trainDataSize * columnSize *sizeof(double)  ,cudaMemcpyDeviceToHost); //将训练集的数据拷入到显存中)
//    //打印结果
//    for(int i=0;i<trainDataSize;i++){
//        for(int j=0;j<columnSize;j++){
//            cout<< doubleArrayResult[i*columnSize + j]<<"    ";
//        }
//        cout<<endl;
//    }



    //释放显存  注意没有释放 size是 columnSize * trainDataSize 的显存 因为后边还需要使用
    cudaFree(cudaDoubleArray);
    cudaFree(cudaTestArrayPiece);
//    cudaFree(cudaAfterSubAndSquareDoubleArrayResult);  //注意这里不进行释放因为还得算下一个函数
    //释放内存
    free(doubleArrayA);
    free(doubleArrayB);

    double *distanceArray = new double[trainDataSize]; //申请空间 用来存放距离数组
    double *cudaDistanceArray; //申请空间 用来存放距离数组
    cudaMalloc((void**)&cudaDistanceArray,sizeof(double) * trainDataSize ); //申请存放距离显存空间
    sumMatrix<<<dim3(trainDataSize/threadSize),dim3(threadSize)>>>(cudaAfterSubAndSquareDoubleArrayResult,cudaDistanceArray,columnSize);
    cudaMemcpy(distanceArray,cudaDistanceArray,sizeof(double) *trainDataSize ,cudaMemcpyDeviceToHost);

//    for(int i=0;i<trainDataSize ;i++ ){
//        cout<<distanceArray[i]<<endl;
//    }


    //计算好距离之后需要把数据和真实值对应起来
     auto *realityAndDistanceMap = new map<double,string>;
     for(int i=0;i<trainDataSize;i++){
         realityAndDistanceMap->insert(pair<double,string>(distanceArray[i] ,resultVector->at(i)));
     }


    // 2.按照升序排序
    // 3.取前k个


    // 4.统计权重 结果更加准确
    auto *weightMap = new map<string,double>;
    auto  setItr = resultSet->begin();
    for(;setItr!=resultSet->end();setItr++){
        weightMap->insert(pair<string,double>(*setItr,0));
    }
    map<double,string>::iterator iter;
    iter = realityAndDistanceMap->begin();
    for(int i=0;i<k;i++,iter++){ //计算sum值 计算出来sum值
        sum  += iter->first;
    }

    iter = realityAndDistanceMap->begin();
    for(int i=0;i<k;i++ ,iter++){  //前k个元素的权重算出来
        (*weightMap)[iter->second] += 1 - (iter->first / sum) ; //距离越近 权重越高
    }



    for(pair<string,double> p :*weightMap ){
        if(p.second > maxWeight){
            maxWeight = p.second;
            maxWeightStr = p.first;
        }
    }

//    if(resultVector->at(position) == realityAndDistanceMap->begin()->second){
//        cout<<"预测正确"<<endl;
//        return true;
//    }
    if(resultVector->at(position).compare(maxWeightStr)  == 0){
//        cout<<"预测正确"<<endl;
        return true;
    }
    else{
//        cout<<"预测错误"<<endl;
        return false;
    }
}


int main() {
    int k=10; //  用来设置取前 k 个距离最近的数据
    //第一步 初始化所有参数
    vector<vector<double>> *doubleDataArray = nullptr; //二维数组 用来存放数据
    vector<string> * headerNameVector = nullptr;
    vector<string> * resultVector = nullptr;
    set<string> * realitySet = nullptr;
    ifstream inputFile;   //定义文件输入流
    string fileName = "../diabetes.csv";  //定义文件名字
    inputFile.open(fileName);  //打开文件
    Csv * csvReader = new Csv(&inputFile);  //把文件句柄传进去
    realitySet = csvReader->getResultSet();
    headerNameVector =  csvReader->getHeaderNameVector(); //获取头名字数组 不包括结果列名字
    doubleDataArray = csvReader->getDoubleData(); //把所有的数据拿到
//    csvReader->printDoubleDataVector(); //打印所有数据
    resultVector = csvReader->getResultVector();
    columnSize = doubleDataArray->at(0).size();  //数据列的数量
    dataSize = doubleDataArray->size();  //记录数据集的行数
    trainDataSize = trainDataProportion * dataSize;  //记录训练集的行数
    testDataSize = dataSize - trainDataSize; //记录测试集的行数
    //random_shuffle(doubleDataArray->begin(),doubleDataArray->end(),myRandom); // 将数据打乱注意第三个参数 myRandom是一个函数地址 是random_shuffle函数 帮你调用
    //进行随机 如果随机数不相同 那么就交换 否则 就
    srand((unsigned int)time(NULL));
    for (int i = 0; i < dataSize; ++i) {
        int n1 = (rand() % dataSize);//产生n以内的随机数  n是数组元素个数
        int n2 = (rand() % dataSize);
        if (n1 != n2) { //若两随机数不相等 则下标为这两随机数的数组进行交换
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
    cout<<"准确率为"<<(float )count/testDataSize *100 <<"%" ;
//    csvReader->printHeaderVector();  //打印头的所有字符串 不包括结果列的名字
//    csvReader->printResultVector(); //打印结果列的数据
//    csvReader->printResultInformation();




}
