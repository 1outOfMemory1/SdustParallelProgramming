//
// Created by ������ on 2020/9/24.
//
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <set>
#include <algorithm>
#ifndef HELLO_CSV_H
#define HELLO_CSV_H

using namespace std;

class Csv {
private:
    ifstream *file;
    string stringOfResult;  //�������ҪԤ����е�����
    set<string> *realitySet; //# ����������洢������ܵ��������� ����Ԥ���Ƿ�ò�ֻ�� ���ֿ��� �ò��Ͳ��ò�
    const char symbol = ',';  //������ʲô���ŷָ� Ĭ�϶�ȡcsv�ļ� �ö��ŷָ�
    vector<string> *rowVector;    //��ߴ�������е��ַ������� ��Ҫ����ת��
    vector<string> * header;  //���ͷ����Ϣ ������Ԥ�������
    vector<vector<double>> *doubleDataArray; //��ά���� �����������
    vector<string> *stringResultVector;  //���ڴ洢������е���������
    void init();  // ��ʼ�� ������̬���ٿռ�ĺ���
    /**
     * @brief �����ַ����ͷָ��� ����һ��string��vector  �൱��python����java��split����
     * @param (string) str   Ҫ�ָ���ַ���
     * @param (char) symbol  �ָ���
     * @return (vector<string>*) ����һ��string��vector
     */
    vector<string>* getStringVector(string str,char symbol);


    /**
     * @brief ��string
     * @param strVector
     * @return
     */
    vector<double>* stringVectorToDoubleVector(vector<string> *strVector);
public:
    Csv(ifstream *file);  //���캯��
    virtual ~Csv();  // ��������  ����freeһЩnew������
    vector<vector<double>> *  getDoubleData();  //��ȡ���ݵĶ���ά����vector
    vector<string> * getHeaderNameVector();
    vector<string> * getResultVector();
    set<string> * getResultSet();
    void printHeaderVector();  //��ӡ Header�е����� ����������е�����
    void printDoubleDataVector();  //��ӡ��������
    void printResultInformation(); //��ӡ�йؽ���е���Ϣ ��������е����� �� ����������п��ܵ�ֵ(���ظ�)
    void printResultVector();   //��ӡ����е���������
};


#endif //HELLO_CSV_H
