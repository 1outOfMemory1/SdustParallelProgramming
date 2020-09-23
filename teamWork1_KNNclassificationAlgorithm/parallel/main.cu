#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>

using namespace std;
__global__ void distance(){

}

__global__ void knn(){

}


vector<string>* getStringVector(string str,char symbol){
    vector<string> *stringVector = new vector<string>;
    vector<int> * positionOfSymbolVector = new vector<int>;
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

vector<double>* getDoubleVector(string str,char symbol){
    vector<double> *doubleVector = new vector<double>;
    vector<int> * positionOfSymbolVector = new vector<int>;
    int positionOfSymbolVectorSize = 0;
    int flag = 0;
    for(int i=0;i<str.length();i++){
        if(str[i] == symbol){
            positionOfSymbolVector->push_back(i);
        }
    }
    positionOfSymbolVectorSize = positionOfSymbolVector->size(); //获取vector大小
    //先取出第一个 字符串
    string temp = str.substr(0,positionOfSymbolVector->at(0));
    doubleVector->push_back(atof(temp.c_str()));
    //取出中间的部分
    for(int i=0;i<positionOfSymbolVectorSize -1;i++){
        temp = str.substr(positionOfSymbolVector->at(i)+1,positionOfSymbolVector->at(i+1) - positionOfSymbolVector->at(i) -1);
        doubleVector->push_back(atof(temp.c_str()));
    }
    //取出最后一个字符串
    temp = str.substr(positionOfSymbolVector->at(positionOfSymbolVectorSize -1) + 1,
                      str.size()- positionOfSymbolVector->at(positionOfSymbolVectorSize -1));
    doubleVector->push_back(atof(temp.c_str()));
//    cout<<"size of stringVector:"<<stringVectorSize<<endl;
    free(positionOfSymbolVector); //释放内存防止内存泄漏
    return doubleVector;
}

//因为vector是连续存储数据的 所以直接进行内存拷贝就行
//memcpy(doubleArray,&doubleVector[0],doubleVectorSize * sizeof(double));


int main() {
    const char symbol = ',';
    vector<string> *rowVector = new vector<string>;
    ifstream inputFile;
    string fileName = "../glass.csv";
    inputFile.open(fileName);
    string row;
    if(!inputFile.is_open()){
        cout<<"打开文件失败 open file failure"<<endl;
        exit(-1);
    }else{
        while (getline(inputFile,row)){
            // cout<<row<<endl;
            // 拿到的数据是这样的 RI,Na,Mg,Al,Si,K,Ca,Ba,Fe,Type
            //1.52101,13.64,4.49,1.1,71.78,0.06,8.75,0,0,1
            rowVector->push_back(row);
        }
    }
    //获取第一行header的信息
    vector<string> * header = getStringVector(rowVector->at(0),symbol);
    for(string temp : *header){
        cout<<temp<<" ";
    }
    cout<<endl;
    vector<double> * doubleVector = getDoubleVector(rowVector->at(1),symbol);
    for(double temp : *doubleVector){
        cout<<temp<<" ";
    }


}
