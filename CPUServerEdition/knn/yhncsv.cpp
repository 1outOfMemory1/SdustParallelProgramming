//
// Created by 尹浩男 on 2020/9/24.
//

#include "yhncsv.h"




void Csv::init() {
    doubleDataArray = new vector<vector<double>>; //二维数组 用来存放数据
    stringOfResult = "";  //这个是需要预测的列的名字
    realitySet = new set<string>; //# 这个是用来存储结果可能的所有种类 比如预测是否得病只有 两种可能 得病和不得病
    rowVector = new vector<string>;    //里边存放了所有的字符串数据 需要进行转换
    stringResultVector = new vector<string>; // 里边存放了最后一行的result数据
    if(!file->is_open()){
        cout<<"open file failure"<<endl;
        exit(-1);
    }
}

vector<string> *Csv::getStringVector(string str, char symbol) {
    auto *stringVector = new vector<string>;
    auto * positionOfSymbolVector = new vector<int>;
    int positionOfSymbolVectorSize = 0;
    for(int i=0;i<str.length();i++){
        if(str[i] == symbol){
            positionOfSymbolVector->push_back(i);
        }
    }
    positionOfSymbolVectorSize = positionOfSymbolVector->size(); //获取vector大小
    //先取出第一个 字符串
    string temp = str.substr(0,positionOfSymbolVector->at(0));
    stringVector->push_back(temp);
    //取出中间的部分
    for(int i=0;i<positionOfSymbolVectorSize -1;i++){
        temp = str.substr(positionOfSymbolVector->at(i)+1,positionOfSymbolVector->at(i+1) - positionOfSymbolVector->at(i) -1);
        stringVector->push_back(temp);
    }
    //取出最后一个字符串
    temp = str.substr(positionOfSymbolVector->at(positionOfSymbolVectorSize -1) + 1,
                      str.size()- positionOfSymbolVector->at(positionOfSymbolVectorSize -1));
    stringVector->push_back(temp);
//    cout<<"size of stringVector:"<<stringVectorSize<<endl;
    free(positionOfSymbolVector); //释放内存防止内存泄漏
    return stringVector;
}

vector<double> *Csv::stringVectorToDoubleVector(vector<string> *strVector) {
    auto *doubleVector = new vector<double>;
    for(string ele : *strVector){
        doubleVector->push_back(atof(ele.c_str()));
    }
    return doubleVector;
}


Csv::Csv(ifstream *ffile) :file(ffile){
    init();  //初始化new 一些参数
    string row;
    while (getline(*file,row)){
        // cout<<row<<endl;
        // 拿到的数据是这样的 RI,Na,Mg,Al,Si,K,Ca,Ba,Fe,Type
        //1.52101,13.64,4.49,1.1,71.78,0.06,8.75,0,0,1
        rowVector->push_back(row);  //把每一行字符串填入vector
    }
    //获取第一行header的信息
    header = getStringVector(rowVector->at(0),symbol);
    stringOfResult = header->back();  //获取 需要预测的列的名字
    header->pop_back();  //弹出最后的元素
    // 获取之后的所有数据 去除了结果行
    for(int i=1;i<rowVector->size();i++){
        vector<string> * tempStringVector = getStringVector(rowVector->at(i),symbol);  //先统一转换为字符串vector
        string temp = tempStringVector->back();
        stringResultVector->push_back(temp);  //把所有的结果存成一个vector 用来计算准确率的时候用
        realitySet->insert(temp); //把最后一列 需要预测的种类 全部存入不可重复的set中去
        tempStringVector->pop_back(); //弹出最后一个元素
        vector<double> * tempDoubleVector = stringVectorToDoubleVector(tempStringVector); //然后再进行从字符串vector向doubleVector的转换
        doubleDataArray->push_back(*tempDoubleVector);   //将得到的转换完成的doubleVector 存入二维数组中
        free(tempStringVector);  //释放到临时的stringVector
    }
    free(rowVector); //用完rowVector就释放掉
}

vector<vector<double>> *Csv::getDoubleData() {
    return doubleDataArray;
}

vector<string> *Csv::getResultVector() {
    return stringResultVector;
}

Csv::~Csv() {
    free(stringResultVector); //释放掉
    free(realitySet);  //释放set
    while(doubleDataArray->empty()){  //从尾部依次释放申请的空间
        free(&doubleDataArray->back());  //释放掉一维数组
        doubleDataArray->pop_back(); // 将元素弹出
    }
    free(doubleDataArray); //最终释放二维数组
}

vector<string> *Csv::getHeaderNameVector() {
    return header;
}

set<string> *Csv::getResultSet() {
    return realitySet;
}


void Csv::printHeaderVector() {
    cout<<"the judgement basis are: ";//判断依据是
    for(string temp : *header){
        cout<<temp<<" ";
    }
    cout<<endl;
}

void Csv::printDoubleDataVector() {
    for(vector<double> doubleTempVector : *doubleDataArray){
        for(double temp : doubleTempVector){
            cout<<temp<<" ";
        }
        cout<<endl;
    }
}

void Csv::printResultInformation(){
    cout<<"The name of result column  is "<<stringOfResult<<" ";//结果所在的列名称是：
    cout<<"All possible parameters of the value to be predicted are(without repetition)"; //需要预测的值的所有可能参数(无重复)有 
    for(string str : *realitySet){
        cout<<str<<" ";
    }
    cout<<endl;
}

void Csv::printResultVector() {
    for(string temp:*stringResultVector){
        cout<<temp<<" ";
    }
    cout<<endl;
}











