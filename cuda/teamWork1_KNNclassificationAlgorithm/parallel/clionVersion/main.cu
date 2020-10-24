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
int k=14; //  用来设置取前 k 个距离最近的数据
double allKernelFunctionCostTime = 0;
double allCostTime = 0;
string fileName = "F://fashion-mnist_train.csv";  //定义文件名字



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

__global__ void sumMatrix(double *aa,double *distance,int columnSize){ //计算每行的和 然后开方
    int x = blockIdx.x *blockDim.x + threadIdx.x;
    double value = 0;
    for(int i=0;i<columnSize;i++){
        value += aa[x * columnSize + i];
    }
    distance[x] = sqrt(value);
}


//这个knn函数的一次运行 算出的是  一行测试数据 距离  所有训练集所有行的距离 然后根据最近的k个数据来预测值
bool knn(vector<double> * testPiece, int position ,vector<vector<double>> *doubleDataVector,vector<string> * resultVector,set<string>* resultSet){
    //1. 初始化一些变量
    //1.1 基本变量的初始化
    double maxWeight = -1;  // 用来存储最大权重
    string maxWeightStr = "";  // 用来存储最大权重的字符串  也就是预测值
    bool flag = false;   // 返回给主函数 用于判断预测是否正确
    double sum = 0;  //这个数据用于之后计算权值的时候用 谁离得最近 权值越高
    auto *doubleArrayA = new double[trainDataSize * columnSize]; // 用于在传输数据的时候用数组临时存储训练集数组 vector行不通 把值逐个赋值给数组 vector不行
    auto *doubleArrayB = new double[columnSize]; //是用来存储测试集的一行数据的 和上方一样
    //    double * doubleArrayResult = new double[trainDataSize*columnSize];  //用于存储中间数据 经过相减平方后的数据 调试时可以输出
    //1.2 映射指针的创建 定义指针 用来映射显存中的数据
    double *cudaDoubleArray; //整个数据二维数组 显存中的数据
    double *cudaTestArrayPiece; //一行测试集数据 显存中的数据
    double *cudaAfterSubAndSquareDoubleArrayResult; //中间数据  显存中的数据
    //1.3 核函数规模的定义 第一个是矩阵减法 和 平方的核函数
    dim3 firstBlocksPerGrid(trainDataSize/threadSize,columnSize/threadSize);
    dim3 firstThreadsPerBlock(threadSize,threadSize);
    dim3 secondBlocksPerGrid(trainDataSize/threadSize);
    dim3 secondThreadsPerBlock(threadSize);
    //2. 申请空间
    cudaMalloc((void**)&cudaDoubleArray,sizeof(double) * trainDataSize * columnSize ); //申请显存中二维数组的空间 用于存放训练集数据
    cudaMalloc((void**)&cudaTestArrayPiece,sizeof(double) * columnSize);  //申请测试数据一维数组的空间 二维训练集的每一行都减去一维测试集的对应位的数据 然后平方
    cudaMalloc((void**)&cudaAfterSubAndSquareDoubleArrayResult,sizeof(double) * trainDataSize * columnSize ); //申请中间结果的显存空间 规模和训练集一样
    //3.拷贝数据进入显存
    //3.1拷贝训练集显存
    //目前是没有什么好办法 只能挨个进行赋值 应该也不慢 但是肯定比那些直接进行内存整块拷贝的慢
    //3.1.1 先把数据弄到一个double数组中去
    for(int i=0;i<trainDataSize;i++){
        for(int j =0;j<columnSize;j++){
            doubleArrayA[i* columnSize +j] = doubleDataVector->at(i).at(j);
        }
    }
    //3.1.2 执行cuda显存拷贝函数
    cudaMemcpy(cudaDoubleArray,doubleArrayA,sizeof(double)  * columnSize * trainDataSize ,cudaMemcpyHostToDevice); //将训练集的数据拷入到显存中
    //3.2 拷贝测试集数据 只有一行 所以可以用copy函数
    //3.2.1 从vector<double> 转换为 double 数组
    copy(testPiece->begin(),testPiece->end(),doubleArrayB);  //分别表示 要复制的vector的头, 要复制的vector的尾 , 目标数组
    //3.2.2 执行cuda显存拷贝函数
    cudaMemcpy(cudaTestArrayPiece,doubleArrayB ,sizeof(double) * columnSize ,cudaMemcpyHostToDevice); //将test的数据传入
    //4. 执行第一个核函数
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

    //将结果拷贝回来  这一步是中间步骤 调试的时候排错用
//    cudaMemcpy(doubleArrayResult,cudaAfterSubAndSquareDoubleArrayResult,trainDataSize * columnSize *sizeof(double)  ,cudaMemcpyDeviceToHost); //将训练集的数据拷入到显存中)
//    //打印计算的中间结果 中间步骤 调试使用
//    for(int i=0;i<trainDataSize;i++){
//        for(int j=0;j<columnSize;j++){
//            cout<< doubleArrayResult[i*columnSize + j]<<"    ";
//        }
//        cout<<endl;
//    }
    //5. 释放一部分显存和内存  注意没有释放 cudaAfterSubAndSquareDoubleArrayResult 因为中间结果还需要使用
    //5.1 释放显存
    cudaFree(cudaDoubleArray); //释放 二维数组(排布为一维) 训练集数据
    cudaFree(cudaTestArrayPiece); //释放 一维数组 测试集的一行数据
    //5.2 释放内存
    free(doubleArrayA);
    free(doubleArrayB);
    //6 为执行第二个核函数准备空间(内存和显存)
    auto *distanceArray = new double[trainDataSize]; //申请内存空间 用来存放距离数组
    double *cudaDistanceArray; //申请空间 映射显存空间 用来存放距离数组
    cudaMalloc((void**)&cudaDistanceArray,sizeof(double) * trainDataSize ); //申请存放距离显存空间
    //7 执行第二个核函数
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
    //8 将最后的距离数组拷贝回内存 以便后边使用
    cudaMemcpy(distanceArray,cudaDistanceArray,sizeof(double) *trainDataSize ,cudaMemcpyDeviceToHost);
    //9 释放掉所有显存 因为以后用不到了
    cudaFree(cudaAfterSubAndSquareDoubleArrayResult);  //释放掉中间数据数组
    cudaFree(cudaDistanceArray);  //释放掉距离数组
//    for(int i=0;i<trainDataSize ;i++ ){  //打印距离数据
//        cout<<distanceArray[i]<<endl;
//    }
    //10 最后的数据处理
    //10.1 初始化一些stl 以后会用到
    auto *realityAndDistanceMap = new multimap<double,string>;  //距离作为key 真实值为value 这样做的好处是自动排序 需要采用multimap 虽然距离一般不能一样 但是就怕巧了
    auto *weightMap = new map<string,double>;  //权重map   后边double数据可以作为依据 key不可能重复 所以放心用 map
    set<string>::iterator setItr ;  //用来遍历所有结果(resultSet) 这个set里存放了结果集的所有可能 比如判断是否得病的数据集 只有得病或者不得病两种 已经是排好序的
    map<double,string>::iterator mapIter; //用于遍历
    //10.2 计算好距离之后需要把数据和真实值对应起来  之后用于统计权值的时候回用到 realityAndDistanceMap multimap<double,string>
    for(int i=0;i<trainDataSize;i++){
        realityAndDistanceMap->insert(pair<double,string>(distanceArray[i] ,resultVector->at(i)));
    }
    free(distanceArray); //顺手把distanceArray释放掉 以后不会再用了
    //10.3.初始化权重map 把value都设成0  统计权重的目的是综合考虑k个最近的点的影响 约接近的点权重越高
    setItr = resultSet->begin();  //resultSet set<string> 的迭代器
    for(;setItr!=resultSet->end();setItr++){
        weightMap->insert(pair<string,double>(*setItr,0));
    }
    //10.4 计算前k个最近的点的总距离sum 用于算权重
    mapIter = realityAndDistanceMap->begin();
    for(int i=0;i<k;i++,mapIter++){ //计算sum值 计算出来sum值
        sum  += mapIter->first;
    }
    //10.5 分别计算前k个点的权值 根据其真实值 加到所有可能的值上 比如得病权重5.4 不得病权重为 8.4 所以可以判断大概率是不得病
    mapIter = realityAndDistanceMap->begin();
    for(int i=0;i<k;i++ ,mapIter++){  //前k个元素的权重算出来
        (*weightMap)[mapIter->second] += 1 - (mapIter->first / sum) ; //距离越近 权重越高  注意这里是 1- xxx
    }
    //10.6 找到最高的那个权重的值 比如是不得病 然后将它赋值给maxWeightStr
    for(pair<string,double> p :*weightMap ){
        if(p.second > maxWeight){
            maxWeight = p.second;
            maxWeightStr = p.first;
        }
    }
    //10.7 根据测试集的真实值和预测值对比是否一样  如果一样说明预测成功
    if(resultVector->at(position).compare(maxWeightStr)  == 0)
        flag = true;  //flag 后边会return回去
    else
        flag = false;
    //11 最终释放掉所有的内存(显存已经全部释放)
    free(realityAndDistanceMap); //释放真实值和距离map
    free(weightMap); //释放权重map
    return flag; //返回预测结果和真实值是否匹配
}


int main(int argc,char * argv[]) {
    clock_t allTimeBegin = clock();
    if(argc > 1){
        fileName = argv[1];
        cout<<"已输入参数， csv文件为 :   "<<argv[1]<<endl<<endl;
    }else{
        cout<<"未输入参数！！！ 默认csv文件是:"<<fileName<<endl;
    }

    //1. 初始化所有参数
    vector<vector<double>> *doubleDataVector = nullptr; //二维数组 用来存放训练集和测试集的所有数据
    vector<string> * resultVector = nullptr;  //结果集 里边全是字符串
    set<string> * realitySet = nullptr;  //无重复的所有结果集
    ifstream inputFile;   //定义文件输入流

    //2.处理i/o流 打开文件 然后调用yhnCsv类来读取csv文件的数据
    inputFile.open(fileName);  //打开文件
    Csv * csvReader = new Csv(&inputFile);  //把文件句柄传进去
    //3. 获取数据
    //3.1 数组或者集合的获取
    realitySet = csvReader->getResultSet();  //获取不重复的数据集
    resultVector = csvReader->getResultVector(); //拿到所有的结果
    doubleDataVector = csvReader->getDoubleData(); //把所有的训练集和测试集的数据拿到

    //3.2 获取全局变量
    columnSize = doubleDataVector->at(0).size();  //数据列的数量
    dataSize = doubleDataVector->size();  //记录总数据集的行数
    trainDataSize = trainDataProportion * dataSize;  //记录训练集的行数  比例乘以 总数据集的行数
    testDataSize = dataSize - trainDataSize; //记录测试集的行数
    //4. 同时对全部数据集和结果数据集进行随机 如果随机数不相同 那么就交换  这样能同时进行多个数组的交换 swap函数很好使
    srand((unsigned int)time(NULL));  //以时间为基准进行随机
    for (int i = 0; i < dataSize; ++i) {  //最多交换 总数据集大小 其实一般就行 不过无所谓了
        int n1 = (rand() % dataSize);//产生n以内的随机数  n是数组元素个数
        int n2 = (rand() % dataSize);
        if (n1 != n2) { //若两随机数不相等 则下标为这两随机数的数组进行交换
            swap(doubleDataVector->at(n1),doubleDataVector->at(n2));
            swap(resultVector->at(n1),resultVector->at(n2));
        }
    }
    csvReader->printHeaderVector();  //打印头的所有字符串 不包括结果列的名字
    csvReader->printResultInformation(); //打印result信息
    cout<<"k值为："<<k<<",总数据集有"<<dataSize<<"条，"<<"训练集有"<<trainDataSize<<"条,"<<"测试集有"<<testDataSize<<"条"<<endl;
    int count = 0; //用来统计成功预测的数量
    for(int i=0;i<testDataSize;i++){
        bool flag =  knn(&doubleDataVector->at(trainDataSize + i), //测试集的一行
                         trainDataSize +i  , //测试集的位置
                         doubleDataVector, // 所有的数据
                         resultVector, //结果的数据集
                         realitySet); //结果的所有可能值 的 set(不重复)
//        bool flag =  knn(&doubleDataVector->at(69), //测试集的一行
//                         69 , //测试集的位置
//                         doubleDataVector, // 所有的数据
//                         resultVector, //结果的数据集
//                         realitySet); //结果的所有可能值 的 set(不重复)
        if(flag){
            count++;
        }
    }
    clock_t allTimeEnd = clock();

    cout<<"此次随机的数据集的准确率为: "<<(float )count/testDataSize *100 <<"%"<<endl ;
    cout<<"all Kernel Function Cost Time: "<<allKernelFunctionCostTime<<" ms"<<endl;
    cout<<"total Cost Time:"<<(allTimeEnd - allTimeBegin)/CLOCKS_PER_SEC <<" s"<<endl;
    free(csvReader);
}
