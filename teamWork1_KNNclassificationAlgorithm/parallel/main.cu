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
    positionOfSymbolVectorSize = positionOfSymbolVector->size(); //��ȡvector��С
    //��ȡ����һ�� �ַ���
    string temp = str.substr(0,positionOfSymbolVector->at(0));
    stringVector->push_back(temp);
    //ȡ���м�Ĳ���
    for(int i=0;i<positionOfSymbolVectorSize -1;i++){
        temp = str.substr(positionOfSymbolVector->at(i)+1,positionOfSymbolVector->at(i+1) - positionOfSymbolVector->at(i) -1);
        stringVector->push_back(temp);
    }
    //ȡ�����һ���ַ���
    temp = str.substr(positionOfSymbolVector->at(positionOfSymbolVectorSize -1) + 1,
                      str.size()- positionOfSymbolVector->at(positionOfSymbolVectorSize -1));
    stringVector->push_back(temp);
//    cout<<"size of stringVector:"<<stringVectorSize<<endl;
    free(positionOfSymbolVector); //�ͷ��ڴ��ֹ�ڴ�й©
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
    positionOfSymbolVectorSize = positionOfSymbolVector->size(); //��ȡvector��С
    //��ȡ����һ�� �ַ���
    string temp = str.substr(0,positionOfSymbolVector->at(0));
    doubleVector->push_back(atof(temp.c_str()));
    //ȡ���м�Ĳ���
    for(int i=0;i<positionOfSymbolVectorSize -1;i++){
        temp = str.substr(positionOfSymbolVector->at(i)+1,positionOfSymbolVector->at(i+1) - positionOfSymbolVector->at(i) -1);
        doubleVector->push_back(atof(temp.c_str()));
    }
    //ȡ�����һ���ַ���
    temp = str.substr(positionOfSymbolVector->at(positionOfSymbolVectorSize -1) + 1,
                      str.size()- positionOfSymbolVector->at(positionOfSymbolVectorSize -1));
    doubleVector->push_back(atof(temp.c_str()));
//    cout<<"size of stringVector:"<<stringVectorSize<<endl;
    free(positionOfSymbolVector); //�ͷ��ڴ��ֹ�ڴ�й©
    return doubleVector;
}

//��Ϊvector�������洢���ݵ� ����ֱ�ӽ����ڴ濽������
//memcpy(doubleArray,&doubleVector[0],doubleVectorSize * sizeof(double));


int main() {
    const char symbol = ',';
    vector<string> *rowVector = new vector<string>;
    ifstream inputFile;
    string fileName = "../glass.csv";
    inputFile.open(fileName);
    string row;
    if(!inputFile.is_open()){
        cout<<"���ļ�ʧ�� open file failure"<<endl;
        exit(-1);
    }else{
        while (getline(inputFile,row)){
            // cout<<row<<endl;
            // �õ��������������� RI,Na,Mg,Al,Si,K,Ca,Ba,Fe,Type
            //1.52101,13.64,4.49,1.1,71.78,0.06,8.75,0,0,1
            rowVector->push_back(row);
        }
    }
    //��ȡ��һ��header����Ϣ
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
