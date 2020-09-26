#include <vector>
#include <string>
#include <ctime>
#include <cstdlib>
#include "yhncsv.h"
#include "common.h"

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

__global__ void knn(){

}


//因为vector是连续存储数据的 所以直接进行内存拷贝就行
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


//这个knn函数的一次运行 算出的是  一行测试数据 距离  所有训练集所有行的距离 然后根据最近的k个数据来预测值
bool knn(vector<double> * testPiece, vector<vector<double>> *doubleDataArray){
    double maxWeight = -1;  // 用来存储最大权重
    string maxWeightStr = "";  // 用来存储最大权重的字符串  也就是预测值
    bool flag = false;   // 返回给主函数 用于判断预测是否正确
    double sum = 0;
    auto *distanceVector = new vector<double>;

    // 1.求距离
    dim3 firstBlocksPerGrid(trainDataSize/threadSize,columnSize/threadSize);
    dim3 firstThreadsPerBlock(threadSize,threadSize);
    //申请空间
    double * result1 = new double[trainDataSize*columnSize];

    double *cudaDoubleArray; //整个数据
    double * cudaTestArrayPiece; //一行测试集数据
    double *cudaAfterSubAndSquareDoubleArrayResult;

    cudaMalloc((void**)&cudaDoubleArray,sizeof(double) * trainDataSize * columnSize ); //申请显存空间
    cudaMalloc((void**)&cudaTestArrayPiece,sizeof(double) * columnSize);  //申请一维数组的空间
    cudaMalloc((void**)&cudaAfterSubAndSquareDoubleArrayResult,sizeof(double) * trainDataSize * columnSize ); //申请显存空间

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
//                   cudaMemcpyHostToDevice); //将训练集的数据拷入到显存中
//    }

    cudaMemcpy(cudaDoubleArray,xxx,
                   sizeof(double)  * columnSize * trainDataSize ,
                   cudaMemcpyHostToDevice); //将训练集的数据拷入到显存中
    double  *yyy = new double[columnSize];
    for(int i=0;i<columnSize;i++){
        yyy[i] = testPiece->at(i);
//        cout<<yyy[i]<<"  ";
    }
    cudaMemcpy(cudaTestArrayPiece,yyy,sizeof(double) * columnSize ,cudaMemcpyHostToDevice); //将test的数据传入


/*
 double *trainSet,  //传入二维数组 每一个都可以
 double *oneRowOftestSet, //需要计算距离测试集的某一行
 double *afterSubAndSquareResultArray //经过减法计算和平方计算后的中间数据
 * */


    //执行核函数
    MatrixSubAndSquare<<<firstBlocksPerGrid,firstThreadsPerBlock>>>(cudaDoubleArray,cudaTestArrayPiece,cudaAfterSubAndSquareDoubleArrayResult,columnSize);
//    MatrixSubAndSquare<<<1,dim3(1,1000)>>>(cudaDoubleArray,cudaTestArrayPiece,cudaAfterSubAndSquareDoubleArrayResult,columnSize);

    //将结果拷贝回来
    cudaMemcpy(result1,cudaAfterSubAndSquareDoubleArrayResult,
                      trainDataSize * columnSize *sizeof(double)  ,
                      cudaMemcpyDeviceToHost); //将训练集的数据拷入到显存中)


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



    // 2.按照升序排序
    // 3.取前k个
    // 4.加权平均


    return false;
}


int main() {
    srand(time(0));   //随机数种子 根据时间生成随机数
    int k=10; //  用来设置取前 k 个距离最近的数据
    //第一步 初始化所有参数
    vector<vector<double>> *doubleDataArray = nullptr; //二维数组 用来存放数据
    vector<string> * headerNameVector = nullptr;
    ifstream inputFile;   //定义文件输入流
    string fileName = "../KNN_Data.csv";  //定义文件名字
    inputFile.open(fileName);  //打开文件
    Csv * csvReader = new Csv(&inputFile);  //把文件句柄传进去
    headerNameVector =  csvReader->getHeaderNameVector(); //获取头名字数组 不包括结果列名字
    doubleDataArray = csvReader->getDoubleData(); //把所有的数据拿到
    columnSize = doubleDataArray->at(0).size();  //数据列的数量
    dataSize = doubleDataArray->size();  //记录数据集的行数
    trainDataSize = trainDataProportion * dataSize;  //记录训练集的行数
    testDataSize = (1-trainDataProportion) * dataSize; //记录测试集的行数
    random_shuffle(doubleDataArray->begin(),doubleDataArray->end(),myRandom); // 将数据打乱注意第三个参数 myRandom是一个函数地址 是random_shuffle函数 帮你调用
    knn(&doubleDataArray->at(trainDataSize),doubleDataArray);


    //    csvReader->printDoubleDataVector(); //打印所有数据
//    csvReader->printHeaderVector();  //打印头的所有字符串 不包括结果列的名字
//    csvReader->printResultVector(); //打印结果列的数据
//    csvReader->printResultInformation();




}
