//
// Created by ������ on 2020/9/24.
//

#include "yhncsv.h"




void Csv::init() {
    doubleDataArray = new vector<vector<double>>; //��ά���� �����������
    stringOfResult = "";  //�������ҪԤ����е�����
    realitySet = new set<string>; //# ����������洢������ܵ��������� ����Ԥ���Ƿ�ò�ֻ�� ���ֿ��� �ò��Ͳ��ò�
    rowVector = new vector<string>;    //��ߴ�������е��ַ������� ��Ҫ����ת��
    stringResultVector = new vector<string>; // ��ߴ�������һ�е�result����
    if(!file->is_open()){
        cout<<"���ļ�ʧ�� open file failure"<<endl;
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

vector<double> *Csv::stringVectorToDoubleVector(vector<string> *strVector) {
    auto *doubleVector = new vector<double>;
    for(string ele : *strVector){
        doubleVector->push_back(atof(ele.c_str()));
    }
    return doubleVector;
}


Csv::Csv(ifstream *ffile) :file(ffile){
    init();  //��ʼ��new һЩ����
    string row;
    while (getline(*file,row)){
        // cout<<row<<endl;
        // �õ��������������� RI,Na,Mg,Al,Si,K,Ca,Ba,Fe,Type
        //1.52101,13.64,4.49,1.1,71.78,0.06,8.75,0,0,1
        rowVector->push_back(row);  //��ÿһ���ַ�������vector
    }
    //��ȡ��һ��header����Ϣ
    header = getStringVector(rowVector->at(0),symbol);
    stringOfResult = header->back();  //��ȡ ��ҪԤ����е�����
    header->pop_back();  //��������Ԫ��
    // ��ȡ֮����������� ȥ���˽����
    for(int i=1;i<rowVector->size();i++){
        vector<string> * tempStringVector = getStringVector(rowVector->at(i),symbol);  //��ͳһת��Ϊ�ַ���vector
        string temp = tempStringVector->back();
        stringResultVector->push_back(temp);  //�����еĽ�����һ��vector ��������׼ȷ�ʵ�ʱ����
        realitySet->insert(temp); //�����һ�� ��ҪԤ������� ȫ�����벻���ظ���set��ȥ
        tempStringVector->pop_back(); //�������һ��Ԫ��
        vector<double> * tempDoubleVector = stringVectorToDoubleVector(tempStringVector); //Ȼ���ٽ��д��ַ���vector��doubleVector��ת��
        doubleDataArray->push_back(*tempDoubleVector);   //���õ���ת����ɵ�doubleVector �����ά������
        free(tempStringVector);  //�ͷŵ���ʱ��stringVector
    }
    free(rowVector); //����rowVector���ͷŵ�
}

vector<vector<double>> *Csv::getDoubleData() {
    return doubleDataArray;
}

vector<string> *Csv::getResultVector() {
    return stringResultVector;
}

Csv::~Csv() {
    free(stringResultVector); //�ͷŵ�
    free(realitySet);  //�ͷ�set
    while(doubleDataArray->empty()){  //��β�������ͷ�����Ŀռ�
        free(&doubleDataArray->back());  //�ͷŵ�һά����
        doubleDataArray->pop_back(); // ��Ԫ�ص���
    }
    free(doubleDataArray); //�����ͷŶ�ά����
}

vector<string> *Csv::getHeaderNameVector() {
    return header;
}

set<string> *Csv::getResultSet() {
    return realitySet;
}


void Csv::printHeaderVector() {
    cout<<"�ж������� : ";
    for(string temp : *header){
        cout<<temp<<" , ";
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

void Csv::printResultInformation() {
    cout<<"������ڵ��������ǣ�"<<stringOfResult<<" ";
    cout<<"��ҪԤ���ֵ�����п��ܲ���(���ظ�)�� ";
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











